import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/music_bloc.dart';

class MusicPlayerPanel extends StatelessWidget {
  const MusicPlayerPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicBloc, MusicState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.currentTrack, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Text("Sharing with group", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () => context.read<MusicBloc>().add(TogglePlayPause()),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: () => context.read<MusicBloc>().add(NextTrack()),
                  ),
                ],
              ),
              Slider(
                value: state.volume,
                onChanged: (val) => context.read<MusicBloc>().add(UpdateVolume(val)),
                activeColor: Colors.orange,
              ),
            ],
          ),
        );
      },
    );
  }
}
