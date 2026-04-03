import 'dart:math' as math;
import 'package:absorb/absorb_game/components/ball.dart';
import 'package:flame/components.dart';

class SpawnSystem {
  static final math.Random _random = math.Random();
  static const double _minBallDistanceFromAbsorber = 50;
  static const int _maxSpawnAttempts = 12;
  static const double _spawnPadding = 20;
  static const double _minBallSpeed = 160;
  static const double _maxBallSpeed = 230;
  double _elapsed = 0;
  double _spawnInterval = 1.0;
  double _difficultyTimer = 0;

  List<Ball> spawnInitial({
    required Vector2 worldSize,
    required Vector2 center,
    required double absorberRadius,
  }) {
    return <Ball>[
      _createBallForType(worldSize, center, absorberRadius, BallType.good),
      _createBallForType(worldSize, center, absorberRadius, BallType.bad),
    ];
  }

  List<Ball> update({
    required double dt,
    required Vector2 worldSize,
    required Vector2 absorberPosition,
    required double absorberRadius,
  }) {
    _elapsed += dt;
    _difficultyTimer += dt;

    if (_difficultyTimer >= 8) {
      _difficultyTimer = 0;
      _spawnInterval = (_spawnInterval - 0.25).clamp(1.0, 3.0);
    }

    if (_elapsed < _spawnInterval) {
      return const <Ball>[];
    }

    _elapsed = 0;
    return <Ball>[
      createRandomBall(worldSize, absorberPosition, absorberRadius),
    ];
  }

  Ball createRandomBall(
    Vector2 gameSize,
    Vector2 absorberPosition,
    double absorberRadius,
  ) {
    final type = _random.nextDouble() > 0.5 ? BallType.good : BallType.bad;
    return _createBallForType(gameSize, absorberPosition, absorberRadius, type);
  }

  Ball _createBallForType(
    Vector2 gameSize,
    Vector2 absorberPosition,
    double absorberRadius,
    BallType type,
  ) {
    for (var i = 0; i < _maxSpawnAttempts; i++) {
      final x =
          _spawnPadding +
          _random.nextDouble() * (gameSize.x - (_spawnPadding * 2));
      final y =
          _spawnPadding +
          _random.nextDouble() * (gameSize.y - (_spawnPadding * 2));
      final direction = _random.nextDouble() * math.pi * 2;
      final speed =
          _minBallSpeed +
          _random.nextDouble() * (_maxBallSpeed - _minBallSpeed);
      final ball = Ball(
        type: type,
        position: Vector2(x, y),
        velocity: Vector2(
          math.cos(direction) * speed,
          math.sin(direction) * speed,
        ),
      );

      final minDistance =
          absorberRadius + ball.radius + _minBallDistanceFromAbsorber;
      if (ball.position.distanceToSquared(absorberPosition) >=
          (minDistance * minDistance)) {
        return ball;
      }
    }

    // Fallback: keep the game running even if attempts fail.
    final fallbackX = absorberPosition.x < gameSize.x / 2
        ? gameSize.x - _spawnPadding
        : _spawnPadding;
    const fallbackDirection = math.pi / 4;
    return Ball(
      type: type,
      position: Vector2(fallbackX, 60),
      velocity: Vector2(
        (fallbackX == _spawnPadding ? 1 : -1) *
            math.cos(fallbackDirection) *
            _minBallSpeed,
        math.sin(fallbackDirection) * _minBallSpeed,
      ),
    );
  }
}
