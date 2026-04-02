import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../absorb_game.dart';
import '../state/game_state_bloc.dart';
import 'game_overlays.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameStateBloc(),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatelessWidget {
  const _GameView();

  @override
  Widget build(BuildContext context) {
    final gameStateBloc = context.read<GameStateBloc>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(game: AbsorbGame(gameStateBloc: gameStateBloc)),
            GameOverlays(
              onResetRequested: () {
                gameStateBloc.add(const ResetGame());
              },
            ),
          ],
        ),
      ),
    );
  }
}
