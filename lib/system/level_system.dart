class LevelSystem {
  int level;
  int xp;
  int xpToNextLevel;
  bool isMaxLevel;

  LevelSystem({this.level = 1, this.xp = 0, this.xpToNextLevel = 5, this.isMaxLevel = false});

  void addXP(int amount) {
    if (isMaxLevel) return; // Jika sudah level max, tidak tambah XP
    xp += amount;
    if (xp >= xpToNextLevel) {
      levelUp();
    }
  }

  void levelUp() {
    level++;
    xp = 0;

    if (level == 2) {
      xpToNextLevel = 10;
    } else if (level == 3) {
      xpToNextLevel = 15;
    } else if (level == 4) {
      isMaxLevel = true;
    }
  }

  bool get hasReachedMaxLevel => isMaxLevel;
}
