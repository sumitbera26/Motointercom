import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/rider.dart';
import '../../domain/repository/network_repository.dart';

// Events
abstract class NetworkEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartDiscovery extends NetworkEvent {
  final String name;
  StartDiscovery(this.name);
  @override
  List<Object?> get props => [name];
}

class StopDiscovery extends NetworkEvent {}

class ConnectToRider extends NetworkEvent {
  final Rider rider;
  ConnectToRider(this.rider);
  @override
  List<Object?> get props => [rider];
}

class DisconnectFromRider extends NetworkEvent {
  final String id;
  DisconnectFromRider(this.id);
  @override
  List<Object?> get props => [id];
}

class _UpdateNearbyRiders extends NetworkEvent {
  final List<Rider> riders;
  _UpdateNearbyRiders(this.riders);
  @override
  List<Object?> get props => [riders];
}

class _UpdateConnectedRiders extends NetworkEvent {
  final List<Rider> riders;
  _UpdateConnectedRiders(this.riders);
  @override
  List<Object?> get props => [riders];
}

// State
class NetworkState extends Equatable {
  final List<Rider> nearbyRiders;
  final List<Rider> connectedRiders;
  final bool isDiscovering;
  final bool isAdvertising;

  const NetworkState({
    this.nearbyRiders = const [],
    this.connectedRiders = const [],
    this.isDiscovering = false,
    this.isAdvertising = false,
  });

  NetworkState copyWith({
    List<Rider>? nearbyRiders,
    List<Rider>? connectedRiders,
    bool? isDiscovering,
    bool? isAdvertising,
  }) {
    return NetworkState(
      nearbyRiders: nearbyRiders ?? this.nearbyRiders,
      connectedRiders: connectedRiders ?? this.connectedRiders,
      isDiscovering: isDiscovering ?? this.isDiscovering,
      isAdvertising: isAdvertising ?? this.isAdvertising,
    );
  }

  @override
  List<Object?> get props => [nearbyRiders, connectedRiders, isDiscovering, isAdvertising];
}

// Bloc
class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final NetworkRepository _networkRepository;
  StreamSubscription? _nearbySub;
  StreamSubscription? _connectedSub;

  NetworkBloc(this._networkRepository) : super(const NetworkState()) {
    on<StartDiscovery>((event, emit) async {
      await _networkRepository.startDiscovery(event.name);
      await _networkRepository.startAdvertising(event.name);
      emit(state.copyWith(isDiscovering: true, isAdvertising: true));
      
      _nearbySub?.cancel();
      _nearbySub = _networkRepository.nearbyRiders.listen((riders) {
        add(_UpdateNearbyRiders(riders));
      });

      _connectedSub?.cancel();
      _connectedSub = _networkRepository.connectedRiders.listen((riders) {
        add(_UpdateConnectedRiders(riders));
      });
    });

    on<StopDiscovery>((event, emit) async {
      await _networkRepository.stopDiscovery();
      await _networkRepository.stopAdvertising();
      emit(state.copyWith(isDiscovering: false, isAdvertising: false));
    });

    on<ConnectToRider>((event, emit) async {
      await _networkRepository.connectToRider(event.rider);
    });

    on<DisconnectFromRider>((event, emit) async {
      await _networkRepository.disconnectFromRider(event.id);
    });

    on<_UpdateNearbyRiders>((event, emit) {
      emit(state.copyWith(nearbyRiders: event.riders));
    });

    on<_UpdateConnectedRiders>((event, emit) {
      emit(state.copyWith(connectedRiders: event.riders));
    });
  }

  @override
  Future<void> close() {
    _nearbySub?.cancel();
    _connectedSub?.cancel();
    return super.close();
  }
}
