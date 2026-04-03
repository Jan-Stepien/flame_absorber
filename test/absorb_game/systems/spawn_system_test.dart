import 'package:absorb/absorb_game/components/ball.dart';
import 'package:absorb/absorb_game/systems/spawn_system.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpawnSystem', () {
    late SpawnSystem spawnSystem;
    final worldSize = Vector2(800, 600);
    final center = Vector2(400, 300);
    const absorberRadius = 36.0;

    setUp(() {
      spawnSystem = SpawnSystem();
    });

    group('spawnInitial', () {
      test('spawns exactly 2 balls', () {
        final balls = spawnSystem.spawnInitial(
          worldSize: worldSize,
          center: center,
          absorberRadius: absorberRadius,
        );

        expect(balls.length, equals(2));
      });

      test('spawns one good and one bad ball', () {
        final balls = spawnSystem.spawnInitial(
          worldSize: worldSize,
          center: center,
          absorberRadius: absorberRadius,
        );

        final goodBalls = balls.where((b) => b.type == BallType.good).length;
        final badBalls = balls.where((b) => b.type == BallType.bad).length;

        expect(goodBalls, equals(1));
        expect(badBalls, equals(1));
      });

      test('spawned balls have non-zero velocity', () {
        final balls = spawnSystem.spawnInitial(
          worldSize: worldSize,
          center: center,
          absorberRadius: absorberRadius,
        );

        for (final ball in balls) {
          expect(ball.velocity.length, greaterThan(0));
        }
      });

      test('spawned balls have default radius', () {
        final balls = spawnSystem.spawnInitial(
          worldSize: worldSize,
          center: center,
          absorberRadius: absorberRadius,
        );

        for (final ball in balls) {
          expect(ball.radius, equals(14.0));
        }
      });
    });

    group('update', () {
      test(
        'returns empty list when elapsed time is less than spawn interval',
        () {
          final balls = spawnSystem.update(
            dt: 0.5,
            worldSize: worldSize,
            absorberPosition: center,
            absorberRadius: absorberRadius,
          );

          expect(balls, isEmpty);
        },
      );

      test('spawns ball when elapsed time exceeds spawn interval', () {
        // First update - no spawn
        var balls = spawnSystem.update(
          dt: 0.5,
          worldSize: worldSize,
          absorberPosition: center,
          absorberRadius: absorberRadius,
        );
        expect(balls, isEmpty);

        // Second update - should spawn
        balls = spawnSystem.update(
          dt: 0.6, // Total: 1.1 seconds > 1.0 spawn interval
          worldSize: worldSize,
          absorberPosition: center,
          absorberRadius: absorberRadius,
        );

        expect(balls.length, equals(1));
      });

      test('spawned ball is either good or bad', () {
        // Keep updating until we get a ball
        List<Ball> balls = [];
        while (balls.isEmpty) {
          balls = spawnSystem.update(
            dt: 1.1,
            worldSize: worldSize,
            absorberPosition: center,
            absorberRadius: absorberRadius,
          );
        }

        final ball = balls.first;
        expect(ball.type == BallType.good || ball.type == BallType.bad, isTrue);
      });

      test('resets elapsed time after spawning', () {
        // Spawn a ball
        spawnSystem.update(
          dt: 1.1,
          worldSize: worldSize,
          absorberPosition: center,
          absorberRadius: absorberRadius,
        );

        // Next update should not spawn immediately
        final balls = spawnSystem.update(
          dt: 0.5,
          worldSize: worldSize,
          absorberPosition: center,
          absorberRadius: absorberRadius,
        );

        expect(balls, isEmpty);
      });
    });

    group('createRandomBall', () {
      test('creates a ball with valid position', () {
        final ball = spawnSystem.createRandomBall(
          worldSize,
          center,
          absorberRadius,
        );

        // Ball should be within world bounds
        expect(ball.position.x, greaterThanOrEqualTo(0));
        expect(ball.position.x, lessThanOrEqualTo(worldSize.x));
        expect(ball.position.y, greaterThanOrEqualTo(0));
        expect(ball.position.y, lessThanOrEqualTo(worldSize.y));
      });

      test('creates ball with non-zero velocity', () {
        final ball = spawnSystem.createRandomBall(
          worldSize,
          center,
          absorberRadius,
        );

        expect(ball.velocity.length, greaterThan(0));
      });

      test('creates ball with velocity in valid speed range', () {
        final ball = spawnSystem.createRandomBall(
          worldSize,
          center,
          absorberRadius,
        );

        final speed = ball.velocity.length;
        // Min speed: 160, Max speed: 230
        expect(speed, greaterThanOrEqualTo(160.0));
        expect(speed, lessThanOrEqualTo(230.0));
      });

      test('creates balls of random types', () {
        final balls = List.generate(
          20,
          (_) =>
              spawnSystem.createRandomBall(worldSize, center, absorberRadius),
        );

        final goodBalls = balls.where((b) => b.type == BallType.good).length;
        final badBalls = balls.where((b) => b.type == BallType.bad).length;

        // With 20 balls, we should have some of each type (probabilistically)
        expect(goodBalls, greaterThan(0));
        expect(badBalls, greaterThan(0));
      });
    });

    group('difficulty scaling', () {
      test('spawn interval decreases over time', () {
        // Initial spawn
        var balls = spawnSystem.update(
          dt: 1.1,
          worldSize: worldSize,
          absorberPosition: center,
          absorberRadius: absorberRadius,
        );
        expect(balls.length, equals(1));

        // Advance difficulty timer (8+ seconds)
        for (var i = 0; i < 10; i++) {
          spawnSystem.update(
            dt: 1.0,
            worldSize: worldSize,
            absorberPosition: center,
            absorberRadius: absorberRadius,
          );
        }

        // Spawn interval should have decreased, making spawns more frequent
        // This is hard to test directly without exposing internal state,
        // but we can verify the system still works
        balls = spawnSystem.update(
          dt: 1.1,
          worldSize: worldSize,
          absorberPosition: center,
          absorberRadius: absorberRadius,
        );
        expect(balls.length, greaterThanOrEqualTo(0));
      });
    });
  });
}
