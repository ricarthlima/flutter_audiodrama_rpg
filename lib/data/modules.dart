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
    name: "Mapas de batalha",
    description: "Ativar os Mapas de Batalha, grids e tokens.",
  );

  static Module get combat => Module(
    id: "COMBAT",
    name: "Combate avançado",
    description: "Ativar iniciativa, ordem de turnos e dano ao corpo.",
  );

  static Module get resisted => Module(
    id: "RESISTED",
    name: "Testes resistidos",
    description:
        "(Regra legado) Permite rolagem contra DT10 para obter sucesso.",
  );

  static List<Module> get all => [magic, grid, combat, resisted];
}

const String energySpellModuleSCC = "ENERGY_SPELL_MODULE_SCC";
