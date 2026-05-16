import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/intercom_packet.dart';
import '../../domain/repository/audio_repository.dart';
import '../../domain/repository/network_repository.dart';

enum IntercomMode { ptt, open, vox }

// Events
abstract class IntercomEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SetIntercomMode extends IntercomEvent {
  final IntercomMode mode;
  SetIntercomMode(this.mode);
  @override
  List<Object?> get props => [mode];
}

class StartTalking extends IntercomEvent {}
class StopTalking extends IntercomEvent {}

class _ReceivedAudioPacket extends IntercomEvent {
  final IntercomPacket packet;
  _ReceivedAudioPacket(this.packet);
  @override
  List<Object?> get props => [packet];
}

// State
class IntercomState extends Equatable {
  final IntercomMode mode;
  final bool isTalking;
  final bool isReceiving;
  final String? activeSpeakerId;

  const IntercomState({
    this.mode = IntercomMode.ptt,
    this.isTalking = false,
    this.isReceiving = false,
    this.activeSpeakerId,
  });

  IntercomState copyWith({
    IntercomMode? mode,
    bool? isTalking,
    bool? isReceiving,
    String? activeSpeakerId,
  }) {
    return IntercomState(
      mode: mode ?? this.mode,
      isTalking: isTalking ?? this.isTalking,
      isReceiving: isReceiving ?? this.isReceiving,
      activeSpeakerId: activeSpeakerId ?? this.activeSpeakerId,
    );
  }

  @override
  List<Object?> get props => [mode, isTalking, isReceiving, activeSpeakerId];
}

// Bloc
class IntercomBloc extends Bloc<IntercomEvent, IntercomState> {
  final AudioRepository _audioRepository;
  final NetworkRepository _networkRepository;
  StreamSubscription? _audioSub;
  StreamSubscription? _incomingSub;

  IntercomBloc(this._audioRepository, this._networkRepository) : super(const IntercomState()) {
    
    _incomingSub = _networkRepository.incomingPackets.listen((packet) {
      if (packet.type == PacketType.audio) {
        add(_ReceivedAudioPacket(packet));
      }
    });

    on<SetIntercomMode>((event, emit) {
      if (event.mode == IntercomMode.open) {
        add(StartTalking());
      } else if (state.mode == IntercomMode.open) {
        add(StopTalking());
      }
      emit(state.copyWith(mode: event.mode));
    });

    on<StartTalking>((event, emit) async {
      if (state.isTalking) return;
      await _audioRepository.startRecording();
      emit(state.copyWith(isTalking: true));
      
      _audioSub?.cancel();
      _audioSub = _audioRepository.audioStream.listen((opusData) {
        _networkRepository.broadcastPacket(IntercomPacket.audio("me", opusData));
      });
    });

    on<StopTalking>((event, emit) async {
      if (!state.isTalking) return;
      _audioSub?.cancel();
      await _audioRepository.stopRecording();
      emit(state.copyWith(isTalking: false));
    });

    on<_ReceivedAudioPacket>((event, emit) async {
      await _audioRepository.playAudioPacket(event.packet.data!);
      emit(state.copyWith(
        isReceiving: true, 
        activeSpeakerId: event.packet.senderId
      ));
      
      // Auto reset receiving state after short timeout for UI feedback
      // In production, use a more robust detection
      Timer(const Duration(milliseconds: 500), () {
        if (!isClosed) {
          emit(state.copyWith(isReceiving: false, activeSpeakerId: null));
        }
      });
    });
  }

  @override
  Future<void> close() {
    _audioSub?.cancel();
    _incomingSub?.cancel();
    return super.close();
  }
}
