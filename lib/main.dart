import 'package:absorb/shared/observers/simple_bloc_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'game/ui/game_screen.dart';

void main() {
  Bloc.observer = const SimpleBlocObserver();

  runApp(const AbsorbApp());
}

class AbsorbApp extends StatelessWidget {
  const AbsorbApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absorb',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const GameScreen(),
    );
  }
}
