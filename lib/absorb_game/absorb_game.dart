import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';

import 'absorb_game_controller.dart';
import 'states/game_state.dart';
import 'states/game_state_bloc.dart';

/// The game that displays the [AbsorbGameController].
/// The [AbsorbGame] is the main game screen of the application.
///
/// Responsible for injecting top-level required dependencies into the [FlameGame].
class AbsorbGame extends FlameGame with HasCollisionDetection {
  final GameStateBloc _gameStateBloc;

  AbsorbGame({required GameStateBloc gameStateBloc})
    : _gameStateBloc = gameStateBloc;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await add(
      FlameBlocProvider<GameStateBloc, GameState>.value(
        value: _gameStateBloc,
        children: [AbsorbGameController()],
      ),
    );
  }
}
