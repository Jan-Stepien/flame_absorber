import 'package:absorb/absorb_game/absorb_game.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';

import 'absorber.dart';
import 'ball.dart';
import '../states/game_state.dart';
import '../states/game_state_bloc.dart';
import '../systems/collision_system.dart';
import '../systems/spawn_system.dart';

//
class GameController extends Component
    with
        HasGameReference<AbsorbGame>,
        FlameBlocReader<GameStateBloc, GameState> {
  final CollisionSystem _collisionSystem = CollisionSystem();
  final SpawnSystem _spawnSystem = SpawnSystem();

  final List<Ball> _balls = <Ball>[];
  late final Absorber absorber;

  GameController();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      FlameBlocListener<GameStateBloc, GameState>(
        listenWhen: (previous, next) =>
            previous.absorberRadius != next.absorberRadius,
        onNewState: (state) {
          absorber.radius = state.absorberRadius;
          absorber.onGameResize(game.size);
        },
      ),
    );

    add(
      FlameBlocListener<GameStateBloc, GameState>(
        listenWhen: (previous, next) =>
            previous.status != next.status && next.status == GameStatus.playing,
        onNewState: (_) {
          _resetWorld();
        },
      ),
    );

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

    final collisionResult = _collisionSystem.update(
      dt: dt,
      balls: _balls,
      absorber: absorber,
      worldSize: game.size,
    );
    final destroyed = collisionResult.destroyedBalls.toSet();
    _balls.removeWhere(destroyed.contains);
    for (final ball in destroyed) {
      ball.removeFromParent();
    }
    for (final event in collisionResult.events) {
      bloc.add(event);
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

  void _resetWorld() {
    for (final ball in _balls) {
      ball.removeFromParent();
    }
    _balls.clear();

    absorber
      ..radius = GameState.initial.absorberRadius
      ..setPositionImmediate(game.size / 2);

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
    game.add(ball);
  }
}
