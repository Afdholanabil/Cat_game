import 'dart:async';
import 'dart:math';
import 'package:cat_game/actors/cat_player.dart';
import 'package:cat_game/component/fishComponent.dart';
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

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    await loadWorld(currentWorld);

    player = CatPlayer(character: 'Cat')
      ..position = Vector2(50, size.y / 2 - 50)
      ..priority = 1;
    add(player);

    _addControlButtons();

    cam = CameraComponent(world: world)
      ..viewfinder.anchor = Anchor.center
      ..follow(player);
    add(cam);

    hungerText = TextComponent(
        text: 'Hunger= ${player.hungerLevel}', position: Vector2(10, 10));
    add(hungerText);

    hungerTimer = TimerComponent(
        period: 5,
        repeat: true,
        onTick: () {
          decreaseHungerLevel();
        });
    add(hungerTimer);

    _startFishSpawning();

    eatingNotification = SpriteComponent()
      ..sprite = await loadSprite('HUD/HUD_arrow_right.png')
      ..position = Vector2(size.x - 110, 10)
      ..size = Vector2(100, 100);

      levelText = TextComponent(text: 'Level: ${player.level}', position: Vector2(10, 30));
    add(levelText);
  }

  @override
  void update(double dt) {
    super.update(dt);

    double akhirBackgroundX = worldWidth;
    double awalBackgroundX = worldWidth - 1280;

    if (player.playerDirection == PlayerDirection.right) {
      if (player.position.x < size.x - player.size.x - horizontalMargin) {
        player.position.x += player.moveSpeed * dt;
        cam.follow(player);
      } else {
        player.position.x = size.x - player.size.x - horizontalMargin;
        if (background!.parallax!.baseVelocity.x == 0 &&
            player.position.x < akhirBackgroundX) {
          background!.parallax!.baseVelocity.x = player.moveSpeed;
        }
      }
    }

    if (player.position.x >= akhirBackgroundX) {
      cameraLocked = true;
      player.position.x = akhirBackgroundX;
      background!.parallax!.baseVelocity.x = 0;
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

    if (player.position.x <= awalBackgroundX) {
      cameraLocked = true;
      player.position.x = awalBackgroundX;
      background!.parallax!.baseVelocity.x = 0;
    }

    if (player.playerDirection == PlayerDirection.none) {
      background!.parallax!.baseVelocity.x = 0;
    }

    hungerText.text = 'Hunger= ${player.hungerLevel}';
    levelText.text = 'Level: ${player.level}';
  }

  Future<void> loadWorld(int worldIndex) async {
    background = await loadParallaxComponent(
      [ParallaxImageData(backgrounds[worldIndex])],
      baseVelocity: Vector2.zero(),
      velocityMultiplierDelta: Vector2(1.6, 1.0),
      size: Vector2(size.x * 2, size.y),
      repeat: ImageRepeat.repeat,
    );
    add(background!);
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

      // TimerComponent untuk menghapus ikan setelah 10 detik, hanya jika masih ada
      final removeFishTimer = TimerComponent(
        period: 10,
        repeat: false,
        onTick: () {
          // Cek apakah ikan masih memiliki parent sebelum menghapus
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
    add(eatingNotification); // Tambahkan notifikasi ke layar

    final hideNotificationTimer = TimerComponent(
      period: 2.0, // Menyembunyikan notifikasi setelah 3 detik
      repeat: false,
      onTick: () {
        eatingNotification
            .removeFromParent(); // Sembunyikan notifikasi setelah 3 detik
      },
    );

    add(hideNotificationTimer); // Tambahkan timer untuk menyembunyikan notifikasi
  }

  void decreaseHungerLevel() {
    if (player.hungerLevel > 0) {
      player.hungerLevel--;
      player.updateIdleState();
      hungerText.text = "Hungry = ${player.hungerLevel}";
    }
  }

  void updateLevelHUD(int newLevel) {
    levelText.text = 'Level: $newLevel'; // Perbarui level di HUD
  }
}
