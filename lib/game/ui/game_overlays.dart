import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/game_state.dart';
import '../state/game_state_bloc.dart';

class GameOverlays extends StatelessWidget {
  final VoidCallback onResetRequested;

  const GameOverlays({super.key, required this.onResetRequested});

  @override
  Widget build(BuildContext context) {
    final score = context.select((GameStateBloc bloc) => bloc.state.score);
    final lives = context.select((GameStateBloc bloc) => bloc.state.lives);
    final status = context.select((GameStateBloc bloc) => bloc.state.status);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score: $score   Lives: $lives   Status: $status',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (status == GameStatus.gameOver)
              FilledButton(
                onPressed: onResetRequested,
                child: const Text('Reset'),
              ),
          ],
        ),
      ),
    );
  }
}
