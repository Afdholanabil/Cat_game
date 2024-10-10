

import 'package:cat_game/game/cat_journey.dart';
import 'package:cat_game/system/level_system.dart';

class WorldManager {
  final CatJourney gameRef;
  int currentWorld = 0;

  WorldManager(this.gameRef);

  void restartGame() {
    currentWorld = 0;
    gameRef.loadWorld(currentWorld); // Kembali ke world pertama
    gameRef.player.levelSystem = LevelSystem(); // Reset level system
    gameRef.updateLevelHUD(1);
  }

  void nextWorld() {
    if (currentWorld < backgrounds.length - 1) {
      currentWorld++;
      gameRef.loadWorld(currentWorld); // Pergi ke world berikutnya
      gameRef.updateLevelHUD(gameRef.player.levelSystem.level);
    }
  }

  bool isMaxWorld() {
    return currentWorld == backgrounds.length - 1;
  }
}
