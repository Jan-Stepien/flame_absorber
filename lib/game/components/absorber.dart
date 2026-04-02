import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class Absorber extends CircleComponent with CollisionCallbacks, DragCallbacks {
  static const double defaultRadius = 36;
  static const double _followSpeed = 900;
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
    add(CircleHitbox());
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _clampVectorToWorld(position);
    _clampVectorToWorld(_targetPosition);
  }

  void setTargetPosition(Vector2 target) {
    _targetPosition.setFrom(target);
    _clampVectorToWorld(_targetPosition);
  }

  /// Sets [position] and [_targetPosition] to the same world-clamped point.
  void setPositionImmediate(Vector2 worldPosition) {
    position.setFrom(worldPosition);
    _clampVectorToWorld(position);
    _targetPosition.setFrom(position);
  }

  void _clampVectorToWorld(Vector2 v) {
    final game = findGame();
    if (game == null || !game.hasLayout) {
      return;
    }
    final r = radius;
    final maxX = math.max(r, game.size.x - r);
    final maxY = math.max(r, game.size.y - r);
    v.x = v.x.clamp(r, maxX);
    v.y = v.y.clamp(r, maxY);
  }

  void _setPositionFromDrag(Vector2 canvasPosition) {
    position.setFrom(canvasPosition);
    _clampVectorToWorld(position);
    _targetPosition.setFrom(position);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _setPositionFromDrag(event.canvasPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _setPositionFromDrag(event.canvasEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _clampVectorToWorld(position);
    _targetPosition.setFrom(position);
    super.onDragEnd(event);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final delta = _targetPosition - position;
    final distance = delta.length;
    if (distance == 0) {
      return;
    }

    final maxStep = _followSpeed * dt;
    if (distance <= maxStep) {
      position.setFrom(_targetPosition);
      return;
    }

    delta.scale(maxStep / distance);
    position += delta;
    _clampVectorToWorld(position);
  }
}
