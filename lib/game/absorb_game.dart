import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';

import 'components/absorber.dart';
import 'components/ball.dart';
import 'state/game_state.dart';
import 'state/game_state_bloc.dart';
import 'systems/collision_system.dart';
import 'systems/spawn_system.dart';

class AbsorbGame extends FlameGame with HasCollisionDetection {
  final CollisionSystem _collisionSystem = CollisionSystem();
  final SpawnSystem _spawnSystem = SpawnSystem();

  final GameStateBloc _gameStateBloc;

  final List<Ball> _balls = <Ball>[];
  late final Absorber _absorber;

  late final FlameBlocProvider<GameStateBloc, GameState> _blocProvider;

  AbsorbGame({required GameStateBloc gameStateBloc})
    : _gameStateBloc = gameStateBloc;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final center = size / 2;

    _blocProvider = FlameBlocProvider<GameStateBloc, GameState>.value(
      value: _gameStateBloc,
      children: const [],
    );
    await add(_blocProvider);

    _absorber = Absorber(position: center);
    await _blocProvider.add(_absorber);
    _spawnInitialBalls(center);
    _gameStateBloc.add(const StartGame());
  }

  @override
  void update(double dt) {
    super.update(dt);
    final status = _gameStateBloc.state.status;
    if (status == GameStatus.gameOver) {
      for (final ball in _balls) {
        ball.velocity.setZero();
      }
    }

    if (status != GameStatus.playing) {
      return;
    }

    final collisionResult = _collisionSystem.update(
      dt: dt,
      balls: _balls,
      absorber: _absorber,
      worldSize: size,
    );
    for (final ball in collisionResult.destroyedBalls) {
      _balls.remove(ball);
      ball.removeFromParent();
    }
    for (final event in collisionResult.events) {
      _gameStateBloc.add(event);
    }

    final newBalls = _spawnSystem.update(
      dt: dt,
      worldSize: size,
      absorberPosition: _absorber.position,
      absorberRadius: _absorber.radius,
    );
    for (final ball in newBalls) {
      _addBall(ball);
    }
  }

  void moveAbsorberTo(Vector2 targetPosition) {
    if (!isLoaded || _gameStateBloc.state.status != GameStatus.playing) {
      return;
    }
    _absorber.setPositionImmediate(targetPosition);
  }

  void _spawnInitialBalls(Vector2 center) {
    final initialBalls = _spawnSystem.spawnInitial(
      worldSize: size,
      center: center,
      absorberRadius: Absorber.defaultRadius,
    );

    for (final ball in initialBalls) {
      _addBall(ball);
    }
  }

  void _addBall(Ball ball) {
    _balls.add(ball);
    _blocProvider.add(ball);
  }
}
