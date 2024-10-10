import 'dart:async';
import 'package:cat_game/component/fishComponent.dart';
import 'package:cat_game/game/cat_journey.dart';
import 'package:cat_game/system/level_system.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

enum PlayerState { idle, running }

enum PlayerDirection { left, right, none }

class CatPlayer extends SpriteAnimationGroupComponent<String>
    with HasGameRef<CatJourney>, KeyboardHandler, CollisionCallbacks {
  CatPlayer({
    required this.character,
  }) : super(size: Vector2(200, 200));

  late final SpriteAnimation idleHappyAnimation;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation idleHungryAnimation;
  late final SpriteAnimation idleEatingAnimation;
  late final SpriteAnimation runningAnimation;

  final double stepTime = 0.1;
  String character;

  int hungerLevel = 10;
  bool isEating = false;

  int xp = 0;
  int level = 1;
  final int xpToNextLevel = 3;

  PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;

  LevelSystem levelSystem = LevelSystem();

  @override
  Future<void> onLoad() async {
    idleAnimation =
        await _spriteAnimation('main_character/Cat/cat1_idle_200.png', 4);
    runningAnimation =
        await _spriteAnimation('main_character/Cat/cat1_run_200.png', 8);
    idleHappyAnimation =
        await _spriteAnimation('main_character/Cat/cat1_idle_happy_200.png', 4);
    idleHungryAnimation = await _spriteAnimation(
        'main_character/Cat/cat1_idle_hungry_200.png', 6);
    idleEatingAnimation = await _spriteAnimation(
        'main_character/Cat/cat1_idle_eating_200.png', 7);

    animations = {
      'idle': idleAnimation,
      'running': runningAnimation,
      'idle_happy': idleHappyAnimation,
      'idle_hungry': idleHungryAnimation,
      'idle_eating': idleEatingAnimation,
    };

    current = 'idle';
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (playerDirection == PlayerDirection.none) {
      updateIdleState();
    } else {
      _updatePlayerMovement(dt);
    }
  }

  void _updatePlayerMovement(double dt) {
    double dirX = 0.0;

    switch (playerDirection) {
      case PlayerDirection.right:
        if (!isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        dirX += moveSpeed;
        current = 'running';
        break;

      case PlayerDirection.left:
        if (isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        dirX -= moveSpeed;
        current = 'running';
        break;

      case PlayerDirection.none:
        break;
    }

    velocity = Vector2(dirX, 0.0);
    position += velocity * dt;
  }

  Future<SpriteAnimation> _spriteAnimation(String path, int amount) async {
    final image = await Flame.images.load(path);
    return SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(200),
      ),
    );
  }

  void updateIdleState() {
    if (isEating) {
      current = 'idle_eating';
    } else {
      if (hungerLevel > 7) {
        current = 'idle_happy';
      } else if (hungerLevel >= 5) {
        current = 'idle';
      } else if (hungerLevel <= 4) {
        current = 'idle_hungry';
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is FishComponent) {
      if (!isEating) {
        isEating = true;
        current = 'idle_eating';
        hungerLevel = (hungerLevel < 10) ? hungerLevel + 2 : 10;
        other.removeFromParent();

        if (!levelSystem.hasReachedMaxLevel) {
          levelSystem.addXP(1);
          gameRef.updateLevelHUD(levelSystem.level);
        }

        gameRef.displayEatingNotification();

        final eatingTimer = TimerComponent(
          period: 2.0,
          repeat: false,
          onTick: () {
            isEating = false;
            updateIdleState();
          },
        );
        gameRef.add(eatingTimer);
      }
    }
    super.onCollision(intersectionPoints, other);
  }
}
