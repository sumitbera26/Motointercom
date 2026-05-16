import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/intercom_bloc.dart';
import '../blocs/network_bloc.dart';
import '../widgets/music_player_panel.dart';
import '../widgets/rider_list_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MOTO INTERCOM', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildConnectionStatus(context),
          const Expanded(
            child: RiderListWidget(),
          ),
          _buildIntercomControls(context),
          const MusicPlayerPanel(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Text("SOS", style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          // Trigger SOS
        },
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context) {
    return BlocBuilder<NetworkBloc, NetworkState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: state.isDiscovering ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
          child: Row(
            children: [
              Icon(
                state.isDiscovering ? Icons.radar : Icons.radar_outlined,
                color: state.isDiscovering ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                state.isDiscovering ? "Searching for riders..." : "Discovery stopped",
                style: TextStyle(color: state.isDiscovering ? Colors.green : Colors.grey),
              ),
              const Spacer(),
              Switch(
                value: state.isDiscovering,
                onChanged: (val) {
                  if (val) {
                    context.read<NetworkBloc>().add(StartDiscovery("Rider_${DateTime.now().millisecond}"));
                  } else {
                    context.read<NetworkBloc>().add(StopDiscovery());
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIntercomControls(BuildContext context) {
    return BlocBuilder<IntercomBloc, IntercomState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _modeButton(context, "PTT", IntercomMode.ptt, state.mode),
                  _modeButton(context, "OPEN", IntercomMode.open, state.mode),
                  _modeButton(context, "VOX", IntercomMode.vox, state.mode),
                ],
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTapDown: (_) {
                  if (state.mode == IntercomMode.ptt) {
                    context.read<IntercomBloc>().add(StartTalking());
                  }
                },
                onTapUp: (_) {
                  if (state.mode == IntercomMode.ptt) {
                    context.read<IntercomBloc>().add(StopTalking());
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state.isTalking ? Colors.orange : Colors.grey[850],
                    boxShadow: state.isTalking ? [
                      BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 30, spreadRadius: 10)
                    ] : [],
                    border: Border.all(color: Colors.orange, width: 4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        state.isTalking ? Icons.mic : Icons.mic_none,
                        size: 64,
                        color: state.isTalking ? Colors.white : Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.isTalking ? "TALKING" : "PUSH TO TALK",
                        style: TextStyle(
                          color: state.isTalking ? Colors.white : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _modeButton(BuildContext context, String label, IntercomMode mode, IntercomMode currentMode) {
    final isSelected = mode == currentMode;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.orange : Colors.grey[900],
        foregroundColor: isSelected ? Colors.black : Colors.orange,
      ),
      onPressed: () => context.read<IntercomBloc>().add(SetIntercomMode(mode)),
      child: Text(label),
    );
  }
}
