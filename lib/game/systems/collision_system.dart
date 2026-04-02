import 'package:flame/components.dart';

import '../components/absorber.dart';
import '../components/ball.dart';
import '../models/ball_type.dart';
import '../state/game_state_bloc.dart';

class CollisionUpdateResult {
  final List<GameStateEvent> events;
  final List<Ball> destroyedBalls;

  const CollisionUpdateResult({
    required this.events,
    required this.destroyedBalls,
  });
}

class AbsorberCollisionResult {
  final GameStateEvent event;
  final bool shouldDestroyBall;

  const AbsorberCollisionResult({
    required this.event,
    required this.shouldDestroyBall,
  });
}

class CollisionSystem {
  CollisionUpdateResult update({
    required double dt,
    required List<Ball> balls,
    required Absorber absorber,
    required Vector2 worldSize,
  }) {
    final events = <GameStateEvent>[];
    final destroyedBalls = <Ball>[];
    for (final ball in balls) {
      moveBall(ball, dt);
      handleWallCollision(ball, worldSize);
      final collision = handleAbsorberCollision(ball, absorber);
      if (collision != null) {
        events.add(collision.event);
        if (collision.shouldDestroyBall) {
          destroyedBalls.add(ball);
        }
      }
    }

    for (var i = 0; i < balls.length; i++) {
      for (var j = i + 1; j < balls.length; j++) {
        handleBallBallCollision(balls[i], balls[j]);
      }
    }
    return CollisionUpdateResult(events: events, destroyedBalls: destroyedBalls);
  }

  void moveBall(Ball ball, double dt) {
    ball.position += ball.velocity * dt;
  }

  void handleWallCollision(Ball ball, Vector2 gameSize) {
    final minX = ball.radius;
    final maxX = gameSize.x - ball.radius;
    final minY = ball.radius;
    final maxY = gameSize.y - ball.radius;

    if (ball.position.x <= minX || ball.position.x >= maxX) {
      ball.velocity.x *= -1;
      ball.position.x = ball.position.x.clamp(minX, maxX);
    }
    if (ball.position.y <= minY || ball.position.y >= maxY) {
      ball.velocity.y *= -1;
      ball.position.y = ball.position.y.clamp(minY, maxY);
    }
  }

  AbsorberCollisionResult? handleAbsorberCollision(
    Ball ball,
    Absorber absorber,
  ) {
    final minDistance = ball.radius + absorber.radius;
    if (ball.position.distanceToSquared(absorber.position) > (minDistance * minDistance)) {
      return null;
    }

    final isGoodBall = ball.type == BallType.good;
    final event = isGoodBall ? const GoodBallAbsorbed() : const BadBallAbsorbed();
    if (isGoodBall) {
      return const AbsorberCollisionResult(event: GoodBallAbsorbed(), shouldDestroyBall: true);
    }

    return AbsorberCollisionResult(event: event, shouldDestroyBall: true);
  }

  void handleBallBallCollision(Ball first, Ball second) {
    final distance = first.position.distanceTo(second.position);
    final minDistance = first.radius + second.radius;
    if (distance > minDistance || distance == 0) {
      return;
    }

    // Simple elastic approximation: swap velocities and separate overlap.
    final firstVelocity = first.velocity.clone();
    first.velocity.setFrom(second.velocity);
    second.velocity.setFrom(firstVelocity);

    final normal = (second.position - first.position)..normalize();
    final overlap = minDistance - distance;
    first.position -= normal * (overlap / 2);
    second.position += normal * (overlap / 2);
  }
}
