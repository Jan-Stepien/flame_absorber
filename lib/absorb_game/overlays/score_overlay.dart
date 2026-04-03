import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:absorb/absorb_game/states/game_state_bloc.dart';

class ScoreOverlay extends StatelessWidget {
  const ScoreOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final score = context.select((GameStateBloc bloc) => bloc.state.score);
    final lives = context.select((GameStateBloc bloc) => bloc.state.lives);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Score: $score   Lives: $lives ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
