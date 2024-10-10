import 'package:cat_game/actors/cat_player.dart';
import 'package:cat_game/actors/cat_player2.dart';
import 'package:cat_game/game/cat_game2.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class CatJourney2 extends Component with HasGameRef<CatGame2> {
  final CatPlayer2 catPlayer;
  late TextComponent hungryIndicator;
  late TimerComponent hungryTimer;

  CatJourney2(this.catPlayer);

  @override
  Future<void> onLoad() async {
    // Text component to display the hungry level
    hungryIndicator = TextComponent(
      text: 'Hungry: ${catPlayer.hungry}',
      position: Vector2(10, 10),
    );
    add(hungryIndicator);

    // Timer that decreases the hungry level every 5 seconds
    hungryTimer = TimerComponent(
      period: 5,
      repeat: true,
      onTick: () {
        decreaseHungry();
      },
    );
    add(hungryTimer);
  }

  void decreaseHungry() {
    if (catPlayer.hungry > 0) {
      catPlayer.hungry--;
    
      catPlayer.updateState(); // Update the animation based on hungry level
      hungryIndicator.text = 'Hungry: ${catPlayer.hungry}';
    }
  }
}
