import 'package:absorb/absorb_game/overlays/game_over_overlay.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'absorb_game.dart';
import 'states/game_state_bloc.dart';
import 'overlays/score_overlay.dart';

/// The page that displays the [AbsorbGame].
/// The [AbsorbGamePage] is the home screen of the application.
///
/// This is an example of embedding a [FlameGame] in a Flutter app.
/// Shows how to share [Bloc] state between the [FlameGame] and the Flutter app.
class AbsorbGamePage extends StatelessWidget {
  const AbsorbGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameStateBloc(),
      child: const _AbsorbGameView(),
    );
  }
}

class _AbsorbGameView extends StatelessWidget {
  const _AbsorbGameView();

  @override
  Widget build(BuildContext context) {
    final gameStateBloc = context.read<GameStateBloc>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(game: AbsorbGame(gameStateBloc: gameStateBloc)),
            ScoreOverlay(),
            GameOverOverlay(),
          ],
        ),
      ),
    );
  }
}
