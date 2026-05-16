import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repository/network_repository.dart';
import '../../domain/models/intercom_packet.dart';

// Events
abstract class MusicEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TogglePlayPause extends MusicEvent {}
class NextTrack extends MusicEvent {}
class PreviousTrack extends MusicEvent {}
class UpdateVolume extends MusicEvent {
  final double volume;
  UpdateVolume(this.volume);
  @override
  List<Object?> get props => [volume];
}

// State
class MusicState extends Equatable {
  final bool isPlaying;
  final String currentTrack;
  final double volume;
  final Duration position;
  final Duration duration;

  const MusicState({
    this.isPlaying = false,
    this.currentTrack = "No Track",
    this.volume = 0.5,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  MusicState copyWith({
    bool? isPlaying,
    String? currentTrack,
    double? volume,
    Duration? position,
    Duration? duration,
  }) {
    return MusicState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentTrack: currentTrack ?? this.currentTrack,
      volume: volume ?? this.volume,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [isPlaying, currentTrack, volume, position, duration];
}

// Bloc
class MusicBloc extends Bloc<MusicEvent, MusicState> {
  final NetworkRepository? networkRepository;

  MusicBloc({this.networkRepository}) : super(const MusicState()) {
    on<TogglePlayPause>((event, emit) {
      final newState = state.copyWith(isPlaying: !state.isPlaying);
      emit(newState);
      _broadcastMusicState(newState);
    });

    on<UpdateVolume>((event, emit) {
      emit(state.copyWith(volume: event.volume));
    });

    // Mock track change
    on<NextTrack>((event, emit) {
      final newState = state.copyWith(currentTrack: "Next Track...");
      emit(newState);
      _broadcastMusicState(newState);
    });
  }

  void _broadcastMusicState(MusicState state) {
    networkRepository?.broadcastPacket(IntercomPacket(
      type: PacketType.music,
      senderId: "me",
      metadata: {
        'isPlaying': state.isPlaying,
        'currentTrack': state.currentTrack,
      },
    ));
  }
}
