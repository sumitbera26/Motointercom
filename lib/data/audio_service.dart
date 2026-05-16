import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_opus/flutter_opus.dart';
import 'package:record/record.dart';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import '../domain/repository/audio_repository.dart';

class AudioService implements AudioRepository {
  final AudioRecorder _recorder = AudioRecorder();
  final int sampleRate = 48000;
  final int channels = 1;
  final int frameSize = 960; // 20ms at 48kHz

  OpusEncoder? _encoder;
  OpusDecoder? _decoder;
  
  final StreamController<Uint8List> _audioStreamController = StreamController<Uint8List>.broadcast();
  StreamSubscription? _recordSub;

  AudioService() {
    _encoder = OpusEncoder.create(
      sampleRate: sampleRate,
      channels: channels,
      application: Application.voip,
    );
    _decoder = OpusDecoder.create(
      sampleRate: sampleRate,
      channels: channels,
    );
    _initPlayback();
  }

  Future<void> _initPlayback() async {
    await FlutterPcmSound.setup(sampleRate: sampleRate, channels: channels);
  }

  @override
  Stream<Uint8List> get audioStream => _audioStreamController.stream;

  @override
  Future<void> startRecording() async {
    if (await _recorder.hasPermission()) {
      final stream = await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 48000,
        numChannels: 1,
      ));

      _recordSub = stream.listen((data) {
        final int16Data = Int16List.view(data.buffer);
        // We should really handle chunking to frameSize here
        // For the sake of the prototype, we assume the stream chunks are compatible or 
        // we'd implement a simple buffer.
        try {
          final encoded = _encoder?.encode(int16Data, frameSize);
          if (encoded != null) {
            _audioStreamController.add(encoded);
          }
        } catch (e) {
          // Handle potential frame size mismatch
        }
      });
    }
  }

  @override
  Future<void> stopRecording() async {
    await _recordSub?.cancel();
    await _recorder.stop();
  }

  @override
  Future<void> playAudioPacket(Uint8List opusPacket) async {
    final decoded = _decoder?.decode(opusPacket, frameSize);
    if (decoded != null) {
      // Feed decoded PCM (Int16List) to the sound plugin
      FlutterPcmSound.feed(decoded);
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    // Note: flutter_pcm_sound might not have direct volume control per feed
    // but we can scale the PCM data if needed.
  }

  @override
  Future<void> setVoxThreshold(double threshold) async {
  }

  @override
  void dispose() {
    _encoder?.dispose();
    _decoder?.dispose();
    _recorder.dispose();
    _audioStreamController.close();
    FlutterPcmSound.stop();
  }
}
