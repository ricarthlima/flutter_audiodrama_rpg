String getBaseLevel(int baseLevel) {
  switch (baseLevel) {
    case 0:
      return "Inexperiente";
    case 1:
      return "Capaz";
    case 2:
      return "Experiente";
    case 3:
      return "Mestre";
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

String removeDiacritics(String str) {
  const mapping = {
    'À': 'A',
    'Á': 'A',
    'Â': 'A',
    'Ã': 'A',
    'Ä': 'A',
    'Å': 'A',
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'å': 'a',
    'È': 'E',
    'É': 'E',
    'Ê': 'E',
    'Ë': 'E',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'Ì': 'I',
    'Í': 'I',
    'Î': 'I',
    'Ï': 'I',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'Ò': 'O',
    'Ó': 'O',
    'Ô': 'O',
    'Õ': 'O',
    'Ö': 'O',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'Ù': 'U',
    'Ú': 'U',
    'Û': 'U',
    'Ü': 'U',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'Ç': 'C',
    'ç': 'c',
    'Ñ': 'N',
    'ñ': 'n'
  };

  return str.split('').map((char) => mapping[char] ?? char).join();
}
