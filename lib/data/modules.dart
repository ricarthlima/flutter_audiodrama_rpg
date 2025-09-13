class Module {
  String id;
  String name;
  String description;

  Module({required this.id, required this.name, required this.description});

  static List<Module> get all => [
    Module(
      id: "MAGIC",
      name: "Magia",
      description: "Adicione elementos mágicos a qualquer cenário com ADRPG.",
    ),
  ];
}
