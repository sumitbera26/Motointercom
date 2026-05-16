import 'package:flutter_test/flutter_test.dart';
import 'package:moto_intercom/domain/models/rider.dart';
import 'package:moto_intercom/domain/models/intercom_packet.dart';
import 'dart:typed_data';

void main() {
  group('Model Tests', () {
    test('Rider equality and copyWith', () {
      final rider1 = Rider(id: '1', name: 'Rider 1');
      final rider2 = Rider(id: '1', name: 'Rider 1');
      final rider3 = rider1.copyWith(isConnected: true);

      expect(rider1, equals(rider2));
      expect(rider3.isConnected, isTrue);
      expect(rider3.id, '1');
    });

    test('IntercomPacket audio factory', () {
      final data = Uint8List.fromList([1, 2, 3]);
      final packet = IntercomPacket.audio('sender', data);

      expect(packet.type, PacketType.audio);
      expect(packet.senderId, 'sender');
      expect(packet.data, equals(data));
    });
  });
}
