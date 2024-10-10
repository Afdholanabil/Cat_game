import 'package:cat_game/game/cat_game.dart';
import 'package:cat_game/game/cat_game2.dart';
import 'package:cat_game/game/cat_journey.dart';
import 'package:cat_game/game/cat_journey2.dart';
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  CatJourney game = CatJourney();
  runApp(GameWidget(game: kDebugMode ? CatJourney() : game));
}
