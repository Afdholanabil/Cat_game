import 'package:cat_game/actors/cat_player2.dart';
import 'package:cat_game/game/cat_journey2.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/input.dart';

class CatGame2 extends FlameGame with TapCallbacks {
  late CatPlayer2 catPlayer;
  late CatJourney2 catJourney;

  @override
  Future<void> onLoad() async {
    catPlayer = CatPlayer2();
    catJourney = CatJourney2(catPlayer);

    add(catJourney);
    add(catPlayer);
  }
}