import 'package:absorb/shared/observers/simple_bloc_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'absorb_game/absorb_game_page.dart';

void main() {
  Bloc.observer = const SimpleBlocObserver();

  runApp(const AbsorbApp());
}

/// The main entry point for the application.
/// Initializes the [MaterialApp] with the [AbsorbGamePage] as the home screen.
/// The [AbsorbApp] is the root widget of the application.
class AbsorbApp extends StatelessWidget {
  const AbsorbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absorb',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const AbsorbGamePage(),
    );
  }
}
