import '../../../domain/dto/action_template.dart';

class GroupAction {
  String id;
  int mod;
  bool holdMod;
  bool isWork;
  List<ActionTemplate> listActions;

  GroupAction({
    required this.id,
    required this.mod,
    this.isWork = false,
    required this.holdMod,
    required this.listActions,
  });
}

abstract class GroupActionIds {
  static const String basic = "BASIC";
  static const String resisted = "RESISTED";
  static const String strength = "STRENGTH";
  static const String agility = "AGILITY";
  static const String intellect = "INTELLECT";
  static const String social = "SOCIAL";
}
