import 'action_template.dart';

class ListAction {
  String name;
  bool isWork;
  List<ActionTemplate> listActions;

  ListAction({
    required this.name,
    required this.isWork,
    required this.listActions,
  });
}
