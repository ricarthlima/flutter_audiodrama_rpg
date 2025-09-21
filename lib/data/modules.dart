class Module {
  String id;
  String name;
  String description;

  Module({required this.id, required this.name, required this.description});

  static Module get magic => Module(
    id: "MAGIC",
    name: "Magia",
    description: "Adicione elementos mágicos a qualquer cenário com ADRPG.",
  );

  static Module get grid => Module(
    id: "GRID",
    name: "Mapas de Batalha",
    description: "Ativar os Mapas de Batalha, grids e tokens.",
  );

  static List<Module> get all => [magic, grid];
}

const String energySpellModuleSCC = "ENERGY_SPELL_MODULE_SCC";
