import 'package:absorb/absorb_game/states/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../states/game_state_bloc.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final score = context.select((GameStateBloc bloc) => bloc.state.score);
    final status = context.select((GameStateBloc bloc) => bloc.state.status);

    if (status != GameStatus.gameOver) {
      return const SizedBox.shrink();
    }

    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.black.withAlpha(64)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Game Over',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Your score: $score',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    FilledButton(
                      onPressed: () =>
                          context.read<GameStateBloc>().add(const ResetGame()),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
