import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/network_bloc.dart';
import '../../domain/models/rider.dart';

class RiderListWidget extends StatelessWidget {
  const RiderListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkBloc, NetworkState>(
      builder: (context, state) {
        final allRiders = [
          ...state.connectedRiders,
          ...state.nearbyRiders.where((nr) => !state.connectedRiders.any((cr) => cr.id == nr.id)),
        ];

        if (allRiders.isEmpty) {
          return const Center(child: Text("No riders nearby", style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          itemCount: allRiders.length,
          itemBuilder: (context, index) {
            final rider = allRiders[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: rider.isConnected ? Colors.green : Colors.grey[800],
                child: Text(rider.name[0].toUpperCase()),
              ),
              title: Text(rider.name),
              subtitle: Text(rider.isConnected ? "Connected" : "Tap to connect"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.battery_5_bar, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  const Icon(Icons.signal_cellular_alt, size: 16, color: Colors.green),
                ],
              ),
              onTap: () {
                if (!rider.isConnected) {
                  context.read<NetworkBloc>().add(ConnectToRider(rider));
                }
              },
            );
          },
        );
      },
    );
  }
}
