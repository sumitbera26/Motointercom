import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:nearby_service/nearby_service.dart';
import '../domain/models/rider.dart';
import '../domain/models/intercom_packet.dart';
import '../domain/repository/network_repository.dart';

class NetworkService implements NetworkRepository {
  final _nearbyService = NearbyService();
  
  final StreamController<List<Rider>> _nearbyRidersController = StreamController<List<Rider>>.broadcast();
  final StreamController<List<Rider>> _connectedRidersController = StreamController<List<Rider>>.broadcast();
  final StreamController<IntercomPacket> _incomingPacketsController = StreamController<IntercomPacket>.broadcast();

  Map<String, Rider> _discoveredRiders = {};
  Map<String, Rider> _connectedRiders = {};
  StreamSubscription? _peersSub;
  StreamSubscription? _payloadSub;

  NetworkService() {
    _peersSub = _nearbyService.communication.peersStream.listen(_handlePeersUpdate);
    _payloadSub = _nearbyService.communication.messagesStream.listen(_handleIncomingMessage);
  }

  @override
  Stream<List<Rider>> get nearbyRiders => _nearbyRidersController.stream;

  @override
  Stream<List<Rider>> get connectedRiders => _connectedRidersController.stream;

  @override
  Stream<IntercomPacket> get incomingPackets => _incomingPacketsController.stream;

  @override
  Future<void> startDiscovery(String riderName) async {
    await _nearbyService.initialize(data: NearbyServiceData(deviceName: riderName));
    await _nearbyService.discovery.startDiscovery();
  }

  @override
  Future<void> stopDiscovery() async {
    await _nearbyService.discovery.stopDiscovery();
    _discoveredRiders.clear();
    _nearbyRidersController.add([]);
  }

  @override
  Future<void> startAdvertising(String riderName) async {
    // nearby_service handles advertising/discovery based on platform
    // on iOS it uses Multipeer Connectivity, on Android Wi-Fi Direct
  }

  @override
  Future<void> stopAdvertising() async {
  }

  @override
  Future<void> connectToRider(Rider rider) async {
    final device = NearbyDevice(id: rider.id, displayName: rider.name);
    await _nearbyService.discovery.connect(device);
  }

  @override
  Future<void> disconnectFromRider(String riderId) async {
    final device = NearbyDevice(id: riderId, displayName: "");
    await _nearbyService.discovery.disconnect(device);
  }

  void _handlePeersUpdate(List<NearbyDevice> devices) {
    _discoveredRiders.clear();
    _connectedRiders.clear();

    for (var device in devices) {
      final rider = Rider(
        id: device.id,
        name: device.displayName,
        isConnected: device.status == NearbyDeviceStatus.connected,
      );

      if (rider.isConnected) {
        _connectedRiders[rider.id] = rider;
      } else {
        _discoveredRiders[rider.id] = rider;
      }
    }

    _nearbyRidersController.add(_discoveredRiders.values.toList());
    _connectedRidersController.add(_connectedRiders.values.toList());
  }

  void _handleIncomingMessage(NearbyMessage message) {
    if (message is NearbyMessageText) {
       // Handle text if needed
    } else if (message is NearbyMessageFiles) {
       // Handle files
    }
    // Note: nearby_service 0.2.1 seems to focus on Text and Files.
    // For raw bytes (Audio), we might need to encode bytes as base64 or similar if Bytes payload is not directly exposed 
    // or use a more suitable plugin.
    // However, the architecture is now set for iOS/Android native P2P.
  }

  @override
  Future<void> broadcastPacket(IntercomPacket packet) async {
    final payload = _encodePacket(packet);
    final textMessage = base64Encode(payload);
    
    for (var rider in _connectedRiders.values) {
      await _nearbyService.communication.sendText(
        NearbyMessageText(content: textMessage, receiverId: rider.id)
      );
    }
  }

  @override
  Future<void> sendPacketTo(String riderId, IntercomPacket packet) async {
    final payload = _encodePacket(packet);
    final textMessage = base64Encode(payload);
    await _nearbyService.communication.sendText(
      NearbyMessageText(content: textMessage, receiverId: riderId)
    );
  }

  Uint8List _encodePacket(IntercomPacket packet) {
    final List<int> result = [packet.type.index];
    if (packet.data != null) {
      result.addAll(packet.data!);
    } else if (packet.metadata != null) {
      result.addAll(utf8.encode(json.encode(packet.metadata)));
    }
    return Uint8List.fromList(result);
  }
}
