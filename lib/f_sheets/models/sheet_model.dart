// ignore_for_file: public_member_api_docs, sort_constructors_first
class SheetModel {
  String characterName;
  List<ActionValue> listActionValue;

  SheetModel({
    required this.characterName,
    required this.listActionValue,
  });
}

class ActionValue {
  String actionId;
  int value;

  ActionValue({
    required this.actionId,
    required this.value,
  });
}
