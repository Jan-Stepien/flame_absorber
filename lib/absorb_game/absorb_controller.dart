import 'package:absorb/absorb_game/absorb_game.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';

import 'components/absorber.dart';
import 'components/ball.dart';
import 'components/wall.dart';
import 'package:absorb/absorb_game/states/game_state.dart';
import 'package:absorb/absorb_game/states/game_state_bloc.dart';
import 'package:absorb/absorb_game/systems/spawn_system.dart';

class AbsorbController extends Component
    with
        HasGameReference<AbsorbGame>,
        FlameBlocReader<GameStateBloc, GameState> {
  final SpawnSystem _spawnSystem = SpawnSystem();

  final List<Ball> _balls = <Ball>[];
  final List<Wall> _walls = <Wall>[];
  late final Absorber absorber;

  AbsorbController();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      FlameBlocListener<GameStateBloc, GameState>(
        listenWhen: (previous, next) =>
            previous.status != next.status && next.status == GameStatus.playing,
        onNewState: (_) {
          _resetWorld();
        },
      ),
    );

    _walls.addAll(WallEdge.values.map((edge) => Wall(edge: edge)));
    for (final wall in _walls) {
      wall.layout(game.size);
      add(wall);
    }

    absorber = Absorber(position: game.size / 2);
    add(absorber);

    _spawnInitialBalls(game.size / 2);
    bloc.add(const StartGame());
  }

  @override
  void update(double dt) {
    super.update(dt);
    final status = bloc.state.status;
    if (status == GameStatus.gameOver) {
      for (final ball in _balls) {
        ball.freeze();
      }
      return;
    }

    if (status != GameStatus.playing) {
      return;
    }

    final newBalls = _spawnSystem.update(
      dt: dt,
      worldSize: game.size,
      absorberPosition: absorber.position,
      absorberRadius: absorber.radius,
    );
    for (final ball in newBalls) {
      _addBall(ball);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    for (final wall in _walls) {
      wall.layout(size);
    }
  }

  void _resetWorld() {
    for (final ball in _balls) {
      ball.removeFromParent();
    }
    _balls.clear();

    absorber.setPositionImmediate(game.size / 2);

    _spawnInitialBalls(game.size / 2);
  }

  void _spawnInitialBalls(Vector2 center) {
    final initialBalls = _spawnSystem.spawnInitial(
      worldSize: game.size,
      center: center,
      absorberRadius: absorber.radius,
    );

    for (final ball in initialBalls) {
      _addBall(ball);
    }
  }

  void _addBall(Ball ball) {
    _balls.add(ball);
    add(ball); // Add to GameController, not directly to game
  }
}
