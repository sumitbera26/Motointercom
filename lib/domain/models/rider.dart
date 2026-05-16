import 'package:equatable/equatable.dart';

class Rider extends Equatable {
  final String id;
  final String name;
  final bool isConnected;
  final double? latitude;
  final double? longitude;
  final double batteryLevel;
  final int signalStrength;

  const Rider({
    required this.id,
    required this.name,
    this.isConnected = false,
    this.latitude,
    this.longitude,
    this.batteryLevel = 1.0,
    this.signalStrength = 0,
  });

  Rider copyWith({
    String? id,
    String? name,
    bool? isConnected,
    double? latitude,
    double? longitude,
    double? batteryLevel,
    int? signalStrength,
  }) {
    return Rider(
      id: id ?? this.id,
      name: name ?? this.name,
      isConnected: isConnected ?? this.isConnected,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      signalStrength: signalStrength ?? this.signalStrength,
    );
  }

  @override
  List<Object?> get props => [id, name, isConnected, latitude, longitude, batteryLevel, signalStrength];
}
