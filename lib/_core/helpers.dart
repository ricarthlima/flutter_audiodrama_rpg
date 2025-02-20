String getBaseLevel(int baseLevel) {
  switch (baseLevel) {
    case 0:
      return "Inexperiente";
    case 1:
      return "Mediocre";
    case 2:
      return "Vivência";
    case 3:
      return "Experiente";
  }
  return "";
}

int getCreditByLevel(int level) {
  switch (level) {
    case 0:
      return 500;
    case 1:
      return 750;
    case 2:
      return 1500;
    case 3:
      return 2500;
  }
  return 0;
}
