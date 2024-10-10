import 'dart:async';
import 'dart:math';
import 'package:cat_game/actors/cat_player.dart';
import 'package:cat_game/component/fishComponent.dart';
import 'package:cat_game/system/world_manager.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

List<String> backgrounds = [
  "Environment/background/background1.png",
  "Environment/background/background2.png",
  "Environment/background/background3.png",
];

class CatJourney extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        TapCallbacks,
        HasCollisionDetection {
  late WorldManager worldManager;
  late final CameraComponent cam;
  late CatPlayer player;
  bool showSwitchWorldButton = false;
  SpriteComponent? switchWorldButton;
  int currentWorld = 0;
  final double horizontalMargin = 200;
  bool cameraLocked = false;
  ParallaxComponent? background;
  int hungerIndicator = 10;
  late TimerComponent hungerTimer;

  late SpriteComponent eatingNotification;

  final double worldWidth = 1280;
  final double playerSpeed = 10;

  late double backgroundWidth;
  TimerComponent? fishSpawnTimer;
  late TextComponent hungerText;
  late TextComponent levelText;
  late TextComponent xpText;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    worldManager = WorldManager(this);

    player = CatPlayer(character: 'Cat')
      ..position = Vector2(50, size.y / 2 - 50)
      ..priority = 1;
    add(player);

    _addControlButtons();
    await loadWorld(0);

    cam = CameraComponent(world: world)
      ..viewfinder.anchor = Anchor.center
      ..follow(player);
    add(cam);

    hungerTimer = TimerComponent(
        period: 5,
        repeat: true,
        onTick: () {
          decreaseHungerLevel();
        });
    add(hungerTimer);

    _startFishSpawning();

    eatingNotification = SpriteComponent()
      ..sprite = await loadSprite('HUD/HUD_notif_eating.png')
      ..size = Vector2(150, 45);
  }

  @override
  void update(double dt) {
    super.update(dt);

    hungerText.text = 'Hunger= ${player.hungerLevel}';

    if (player.levelSystem.level == 2 || player.levelSystem.level == 3) {
      changeWorldOnLevelUp();
    } else if (player.levelSystem.hasReachedMaxLevel) {
      restartGameOnMaxLevel();
    }

    if (player.levelSystem.hasReachedMaxLevel) {
      levelText.text = 'Level: MAX';
      xpText.text = 'XP: 15/15';
    } else {
      levelText.text = 'Level: ${player.levelSystem.level}';
      xpText.text =
          'XP: ${player.levelSystem.xp}/${player.levelSystem.xpToNextLevel}';
    }

    double akhirBackgroundX = worldWidth;
    double awalBackgroundX = worldWidth - 1280;

    if (player.playerDirection == PlayerDirection.right) {
      if (player.position.x < size.x - player.size.x - horizontalMargin) {
        player.position.x += player.moveSpeed * dt;
        cam.follow(player);
      } else if (player.position.x < size.x - player.size.x) {
        player.position.x += player.moveSpeed * dt;
      } else {
        player.position.x = size.x - player.size.x;
        if (background!.parallax!.baseVelocity.x == 0 &&
            player.position.x < akhirBackgroundX) {
          background!.parallax!.baseVelocity.x = player.moveSpeed;
        } else {
          background!.parallax!.baseVelocity.x = 0;
        }
      }
    }

    if (player.playerDirection == PlayerDirection.left) {
      if (player.position.x > horizontalMargin) {
        player.position.x -= player.moveSpeed * dt;
        cam.follow(player);
      } else {
        player.position.x = horizontalMargin;
        if (background!.parallax!.baseVelocity.x == 0 &&
            player.position.x > awalBackgroundX) {
          background!.parallax!.baseVelocity.x = -player.moveSpeed;
        }
      }
    }

    if (player.position.x >= akhirBackgroundX) {
      cameraLocked = true;
      player.position.x = akhirBackgroundX;
      background!.parallax!.baseVelocity.x = 0;
    }

    if (player.position.x <= awalBackgroundX) {
      cameraLocked = true;
      player.position.x = awalBackgroundX;
      background!.parallax!.baseVelocity.x = 0;
    }

    if (player.playerDirection == PlayerDirection.none) {
      background!.parallax!.baseVelocity.x = 0;
    }
  }

  Future<void> loadWorld(int worldIndex) async {
    background = await loadParallaxComponent(
      [ParallaxImageData(backgrounds[worldIndex])],
      baseVelocity: Vector2.zero(),
      velocityMultiplierDelta: Vector2(1.5, 1.0),
      size: Vector2(size.x * 2, size.y),
      repeat: ImageRepeat.repeat,
    );
    add(background!);

    _addHUD();
  }

  void _addControlButtons() {
    final leftButton = HudButtonComponent(
      button:
          SpriteComponent.fromImage(images.fromCache('HUD/HUD_arrow_left.png')),
      onPressed: () {
        if (!player.isEating) {
          player.playerDirection = PlayerDirection.left;
        }
      },
      onReleased: () {
        player.playerDirection = PlayerDirection.none;
      },
      position: Vector2(50, size.y - 80),
      size: Vector2(100, 100),
    )..priority = 2;

    final rightButton = HudButtonComponent(
      button: SpriteComponent.fromImage(
          images.fromCache('HUD/HUD_arrow_right.png')),
      onPressed: () {
        if (!player.isEating) {
          player.playerDirection = PlayerDirection.right;
        }
      },
      onReleased: () {
        player.playerDirection = PlayerDirection.none;
      },
      position: Vector2(size.x - 130, size.y - 80),
      size: Vector2(100, 100),
    )..priority = 2;

    add(leftButton);
    add(rightButton);
  }

  void _startFishSpawning() async {
    _spawnFish();

    fishSpawnTimer = TimerComponent(
      period: 10,
      repeat: true,
      onTick: () {
        _spawnFish();
      },
    );
    add(fishSpawnTimer!);
  }

  void _spawnFish() {
    for (int i = 0; i < 5; i++) {
      final randomX = Random().nextDouble() * (worldWidth - 100);
      final randomY = 240.0;
      final fish = FishComponent(
          position: Vector2(randomX, randomY), size: Vector2(50, 50));
      add(fish);

      final removeFishTimer = TimerComponent(
        period: 10,
        repeat: false,
        onTick: () {
          if (fish.parent != null) {
            remove(fish);
          }
        },
      );
      add(removeFishTimer);
    }
  }

  double distance(Vector2 point1, Vector2 point2) {
    return (point1 - point2).length;
  }

  void displayEatingNotification() {
    final notificationPosition = Vector2(
        player.position.x + player.size.x / 2 - eatingNotification.size.x / 2,
        player.position.y);

    eatingNotification.position = notificationPosition;

    add(eatingNotification);

    final hideNotificationTimer = TimerComponent(
      period: 2.0,
      repeat: false,
      onTick: () {
        eatingNotification.removeFromParent();
      },
    );

    add(hideNotificationTimer);
  }

  void decreaseHungerLevel() {
    if (player.hungerLevel > 0) {
      player.hungerLevel--;
      player.updateIdleState();
      hungerText.text = "Hungry = ${player.hungerLevel}";
    }
  }

  void updateLevelHUD(int newLevel) {
    levelText.text = 'Level: $newLevel';
  }

  void changeWorldOnLevelUp() {
    if (player.levelSystem.level == 2 && currentWorld == 0) {
      currentWorld = 1;
      loadWorld(currentWorld);
    } else if (player.levelSystem.level == 3 && currentWorld == 1) {
      currentWorld = 2;
      loadWorld(currentWorld);
    }
  }

  void restartGameOnMaxLevel() {
    if (player.levelSystem.hasReachedMaxLevel) {
      currentWorld = 0;
      loadWorld(currentWorld);
      worldManager.restartGame();
    }
  }

  void _addHUD() {
    hungerText = TextComponent(
        text: 'Hunger= ${player.hungerLevel}', position: Vector2(10, 10));
    levelText = TextComponent(
        text: 'Level: ${player.levelSystem.level}', position: Vector2(10, 40));
    xpText = TextComponent(
        text:
            'XP: ${player.levelSystem.xp}/${player.levelSystem.xpToNextLevel}',
        position: Vector2(10, 70));

    add(hungerText);
    add(levelText);
    add(xpText);
  }
}
