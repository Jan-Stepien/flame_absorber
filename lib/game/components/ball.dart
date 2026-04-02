import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../models/ball_type.dart';

class Ball extends CircleComponent with CollisionCallbacks {
  final BallType type;
  final Vector2 velocity;

  Ball({
    required this.type,
    required this.velocity,
    required super.position,
    double radius = 14,
  }) : super(
         radius: radius,
         anchor: Anchor.center,
         paint: Paint()
           ..color = type == BallType.good ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }
}
