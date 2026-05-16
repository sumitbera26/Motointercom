import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/audio_service.dart';
import 'data/network_service.dart';
import 'presentation/blocs/intercom_bloc.dart';
import 'presentation/blocs/network_bloc.dart';
import 'presentation/blocs/music_bloc.dart';
import 'presentation/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final networkService = NetworkService();
  final audioService = AudioService();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<NetworkService>.value(value: networkService),
        RepositoryProvider<AudioService>.value(value: audioService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => NetworkBloc(networkService)),
          BlocProvider(create: (context) => IntercomBloc(audioService, networkService)),
          BlocProvider(create: (context) => MusicBloc(networkRepository: networkService)),
        ],
        child: const MotoIntercomApp(),
      ),
    ),
  );
}

class MotoIntercomApp extends StatelessWidget {
  const MotoIntercomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moto Intercom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.orange,
          secondary: Colors.orangeAccent,
          surface: Color(0xFF1E1E1E),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
