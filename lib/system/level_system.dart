class LevelSystem {
  int level;
  int xp;
  int xpToNextLevel;

  LevelSystem({this.level = 1, this.xp = 0, this.xpToNextLevel = 5});

  void addXP(int amount) {
    xp += amount;
    if (xp >= xpToNextLevel) {
      levelUp();
    }
  }

  void levelUp() {
    level++;
    xp = 0;

    // Sesuaikan jumlah XP yang dibutuhkan untuk level berikutnya
    if (level == 2) {
      xpToNextLevel = 10;
    } else if (level >= 3) {
      xpToNextLevel = double.infinity.toInt(); // Level 3 dan seterusnya tidak memiliki batas XP
    }
  }
}
