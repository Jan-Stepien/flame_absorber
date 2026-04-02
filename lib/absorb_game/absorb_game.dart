import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';

import 'components/game_controller.dart';
import 'states/game_state.dart';
import 'states/game_state_bloc.dart';

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
        children: [GameController()],
      ),
    );
  }
}
