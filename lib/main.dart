import 'package:cat_game/game/cat_game.dart';
import 'package:cat_game/game/cat_game2.dart';
import 'package:cat_game/game/cat_journey.dart';
import 'package:cat_game/game/cat_journey2.dart';
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import 'package:cat_game/game/cat_journey.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Tambahkan ini untuk mengakses SystemChrome
import 'package:flame/game.dart';
import 'package:cat_game/game/cat_journey.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set orientation to landscape only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  // Fullscreen mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize the game
  final game = CatJourney();

  runApp(GameWidget(game: game));
}


