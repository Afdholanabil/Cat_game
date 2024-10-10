import 'package:flame/components.dart';

class LoopingBackground extends SpriteComponent {
  LoopingBackground({
    required Sprite sprite,
    required Vector2 size,   
    Vector2? position,
    int priority = 0,       
  }) : super(
          sprite: sprite,
          size: size,        
          priority: priority, 
        );

  @override
  void update(double dt) {
    if (position.x + size.x < 0) {
      position.x += size.x * 2;
    }
    super.update(dt);
  }
}
