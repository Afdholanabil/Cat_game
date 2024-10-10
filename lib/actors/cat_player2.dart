import 'package:cat_game/game/cat_game2.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class CatPlayer2 extends SpriteAnimationGroupComponent<String> with HasGameRef<CatGame2> {
  late SpriteAnimation idleAnimation;
  late SpriteAnimation runningAnimation;
  late SpriteAnimation idleHappyAnimation;
  late SpriteAnimation idleHungryAnimation;

  String currentState = 'idle';

  int hungry = 10; // Max hungry is 10, starts fully fed

  CatPlayer2()
      : super(
          size: Vector2(100, 100),
        );

  @override
  Future<void> onLoad() async {
    // Load all animations
    idleAnimation = await _loadAnimation('main_character/Cat/cat1_idle_200.png');
    runningAnimation = await _loadAnimation('main_character/Cat/cat1_run_200.png');
    idleHappyAnimation = await _loadAnimation('main_character/Cat/cat1_idle_happy_200.png');
    idleHungryAnimation = await _loadAnimation('main_character/Cat/cat1_idle_hungry_200.png');

    animations = {
      'idle': idleAnimation,
      'running': runningAnimation,
      'idle_happy': idleHappyAnimation,
      'idle_hungry': idleHungryAnimation,
    };

    current = 'idle_happy';
  }

  Future<SpriteAnimation> _loadAnimation(String path) async {
    final image = await Flame.images.load(path);
    return SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 4, // Assume 4 frames per animation
        stepTime: 0.1,
        textureSize: Vector2(200, 200),
      ),
    );
  }

  void updateState() {
  // Update based on hungry levels
  if (hungry > 7) {  // hungry 8-10 should display happy idle
    current = 'idle_happy';
  } else if (hungry >= 5) {  // hungry 5-7 should display normal idle
    current = 'idle';
  } else {  // hungry 0-4 should display hungry idle
    current = 'idle_hungry';
  }
}

}