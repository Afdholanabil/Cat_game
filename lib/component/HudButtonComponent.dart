import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class HudButtonComponent extends PositionComponent with TapCallbacks {
  final SpriteComponent button;
  final VoidCallback onPressed;
  final VoidCallback onReleased;

  HudButtonComponent({
    required this.button,
    required this.onPressed,
    required this.onReleased,
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    add(button);
  }

  @override
  bool onTapDown(TapDownEvent event) {
    onPressed();
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    onReleased();
    return true;
  }
}
