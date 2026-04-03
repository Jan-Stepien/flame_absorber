import 'package:absorb/absorb_game/components/ball.dart';
import 'package:absorb/absorb_game/states/game_state.dart';
import 'package:absorb/absorb_game/states/game_state_bloc.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';

class Absorber extends CircleComponent
    with
        FlameBlocReader<GameStateBloc, GameState>,
        CollisionCallbacks,
        DragCallbacks {
  static const double defaultRadius = 36;
  static const double _followSpeed = 900;
  static const double _growthRate = 3;
  static const double _initialRadius = 36;

  final Vector2 _targetPosition = Vector2.zero();

  Absorber({required super.position, double radius = defaultRadius})
    : super(
        radius: radius,
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFF6366F1),
      ) {
    _targetPosition.setFrom(position);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(collisionType: CollisionType.active));
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ball) {
      other.removeFromParent();
      bloc.add(
        (other.type == BallType.good)
            ? const GoodBallAbsorbed()
            : const BadBallAbsorbed(),
      );
    }
  }

  void setTargetPosition(Vector2 target) {
    _targetPosition.setFrom(target);
  }

  /// Sets [position] and [_targetPosition] to the same world-clamped point.
  /// Used by Wall collision to enforce boundaries.
  void setPositionImmediate(Vector2 worldPosition) {
    position.setFrom(worldPosition);
    _targetPosition.setFrom(position);
  }

  void _setTargetFromDrag(Vector2 canvasPosition) {
    _targetPosition.setFrom(canvasPosition);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _setTargetFromDrag(event.canvasPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _setTargetFromDrag(event.canvasEndPosition);
  }

  @override
  void update(double dt) {
    super.update(dt);

    radius = bloc.state.score / 10 * _growthRate + _initialRadius;

    if (bloc.state.status != GameStatus.playing) {
      return;
    }

    // Smoothly follow the target position set by drag
    final delta = _targetPosition - position;
    final distance = delta.length;

    if (distance > 0) {
      final maxStep = _followSpeed * dt;
      if (distance <= maxStep) {
        // Close enough, snap to target
        position.setFrom(_targetPosition);
      } else {
        // Move towards target at _followSpeed
        delta.normalize();
        position += delta * maxStep;
      }
    }
  }
}
