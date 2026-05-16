import 'dart:typed_data';
import 'package:equatable/equatable.dart';

enum PacketType { audio, music, location, sos, control }

class IntercomPacket extends Equatable {
  final PacketType type;
  final String senderId;
  final Uint8List? data;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  IntercomPacket({
    required this.type,
    required this.senderId,
    this.data,
    this.metadata,
    DateTime? timestamp,
  }) : this.timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [type, senderId, data, metadata, timestamp];

  // Helper to create audio packet
  factory IntercomPacket.audio(String senderId, Uint8List audioData) {
    return IntercomPacket(
      type: PacketType.audio,
      senderId: senderId,
      data: audioData,
    );
  }

  // Helper to create location packet
  factory IntercomPacket.location(String senderId, double lat, double lon) {
    return IntercomPacket(
      type: PacketType.location,
      senderId: senderId,
      metadata: {'lat': lat, 'lon': lon},
    );
  }
}
