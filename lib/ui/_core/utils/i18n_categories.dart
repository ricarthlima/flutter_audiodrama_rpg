String i18nCategories(String category) {
  switch (category) {
    case "camping":
      return "acampamento";
    case "communication":
      return "comunicação";
    case "exploration":
      return "exploração";
    case "food":
      return "comida";
    case "forest":
      return "floresta";
    case "gun":
      return "armas";
    case "medic":
      return "medicina";
    case "police":
      return "polícia";
    case "survival":
      return "sobrevivência";
    case "tool":
      return "ferramenta";
  }
  return category;
}
