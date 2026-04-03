import 'dart:math' as math;
import 'dart:ui';

import 'package:absorb/absorb_game/components/absorber.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'ball.dart';

enum WallEdge { top, bottom, left, right }

class Wall extends RectangleComponent with CollisionCallbacks {
  static const double thickness = 1;

  final WallEdge edge;

  Wall({required this.edge})
    : super(
        anchor: Anchor.topLeft,
        paint: Paint()..color = const Color(0x00000000),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  void layout(Vector2 gameSize) {
    final w = gameSize.x;
    final h = gameSize.y;
    switch (edge) {
      case WallEdge.top:
        position = Vector2.zero();
        size = Vector2(w, thickness);
        break;
      case WallEdge.bottom:
        position = Vector2(0, h - thickness);
        size = Vector2(w, thickness);
        break;
      case WallEdge.left:
        position = Vector2.zero();
        size = Vector2(thickness, h);
        break;
      case WallEdge.right:
        position = Vector2(w - thickness, 0);
        size = Vector2(thickness, h);
        break;
    }
  }

  /// Handles ball collisions with walls using onCollisionStart for one-time
  /// bounce reactions. Reflects ball velocity and clamps position to prevent
  /// tunneling through walls.
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ball) {
      final game = findGame();
      if (game == null || !game.hasLayout) return;

      final ball = other;
      final gs = game.size;

      switch (edge) {
        case WallEdge.left:
          ball.velocity.x *= -1;
          ball.position.x = math.max(ball.position.x, thickness + ball.radius);
          break;
        case WallEdge.right:
          ball.velocity.x *= -1;
          ball.position.x = math.min(
            ball.position.x,
            gs.x - thickness - ball.radius,
          );
          break;
        case WallEdge.top:
          ball.velocity.y *= -1;
          ball.position.y = math.max(ball.position.y, thickness + ball.radius);
          break;
        case WallEdge.bottom:
          ball.velocity.y *= -1;
          ball.position.y = math.min(
            ball.position.y,
            gs.y - thickness - ball.radius,
          );
          break;
      }
    } else if (other is Absorber) {
      _enforceAbsorberBoundary(other);
    }
  }

  /// Continuously enforces boundary for Absorber
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Absorber) {
      _enforceAbsorberBoundary(other);
    }
  }

  /// Clamps absorber position to prevent passing through this wall edge
  void _enforceAbsorberBoundary(Absorber absorber) {
    final game = findGame();
    if (game == null || !game.hasLayout) return;

    final gs = game.size;

    switch (edge) {
      case WallEdge.left:
        absorber.setPositionImmediate(
          Vector2(
            math.max(absorber.position.x, thickness + absorber.radius),
            absorber.position.y,
          ),
        );
        break;
      case WallEdge.right:
        absorber.setPositionImmediate(
          Vector2(
            math.min(absorber.position.x, gs.x - thickness - absorber.radius),
            absorber.position.y,
          ),
        );
        break;
      case WallEdge.top:
        absorber.setPositionImmediate(
          Vector2(
            absorber.position.x,
            math.max(absorber.position.y, thickness + absorber.radius),
          ),
        );
        break;
      case WallEdge.bottom:
        absorber.setPositionImmediate(
          Vector2(
            absorber.position.x,
            math.min(absorber.position.y, gs.y - thickness - absorber.radius),
          ),
        );
        break;
    }
  }
}
