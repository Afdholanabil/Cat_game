import 'package:cat_game/game/cat_journey.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import 'package:flutter/services.dart';  


void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final game = CatJourney();

  runApp(GameWidget(game: game));
}


