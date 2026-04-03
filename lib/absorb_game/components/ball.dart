import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum BallType { good, bad }

class Ball extends CircleComponent with CollisionCallbacks {
  final BallType type;
  Vector2 velocity;

  Ball({
    required this.type,
    required this.velocity,
    required super.position,
    double radius = 14,
  }) : super(
         radius: radius,
         anchor: Anchor.center,
         paint: Paint()
           ..color = type == BallType.good
               ? const Color(0xFF22C55E)
               : const Color(0xFFEF4444),
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(collisionType: CollisionType.active));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    // Only process collision once per pair (not twice)
    if (other is Ball && hashCode < other.hashCode) {
      _handleBallToBallCollision(other);
    }
  }

  void freeze() {
    velocity.setZero();
  }

  void _handleBallToBallCollision(Ball other) {
    // Simple elastic collision: swap velocities completely
    final temp = velocity.clone();
    velocity.setFrom(other.velocity);
    other.velocity.setFrom(temp);

    // Separate overlapping balls to prevent sticking
    final normal = (other.position - position)..normalize();
    final overlap = radius + other.radius - position.distanceTo(other.position);
    if (overlap > 0) {
      position -= normal * (overlap / 2);
      other.position += normal * (overlap / 2);
    }
  }
}
