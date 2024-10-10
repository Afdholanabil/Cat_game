import 'package:cat_game/game/cat_journey.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class SwitchWorldButton extends SpriteComponent with TapCallbacks, HasGameRef<CatJourney> {
  final VoidCallback onTap;

  SwitchWorldButton({
    required Vector2 position,
    required Vector2 size,
    required this.onTap,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(await gameRef.images.load('HUD/HUD_arrow_right.png'));  // Menggunakan gameRef untuk memuat gambar tombol
  }

  @override
  bool onTapDown(TapDownEvent event) {
    onTap();
    return true;
  }
}