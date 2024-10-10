import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class FishComponent extends SpriteComponent with CollisionCallbacks {
  FishComponent({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    final fishImages = [
      'main_character/fish/fish1.png',
      'main_character/fish/fish2.png',
    ];
    final randomIndex = Random().nextInt(fishImages.length);
    sprite = await Sprite.load(fishImages[randomIndex]);

    add(RectangleHitbox());
  }
}
