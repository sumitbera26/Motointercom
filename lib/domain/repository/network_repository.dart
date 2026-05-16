import '../models/rider.dart';
import '../models/intercom_packet.dart';

abstract class NetworkRepository {
  Stream<List<Rider>> get nearbyRiders;
  Stream<List<Rider>> get connectedRiders;
  Stream<IntercomPacket> get incomingPackets;

  Future<void> startDiscovery(String riderName);
  Future<void> stopDiscovery();
  Future<void> startAdvertising(String riderName);
  Future<void> stopAdvertising();
  
  Future<void> connectToRider(Rider rider);
  Future<void> disconnectFromRider(String riderId);
  
  Future<void> broadcastPacket(IntercomPacket packet);
  Future<void> sendPacketTo(String riderId, IntercomPacket packet);
}
