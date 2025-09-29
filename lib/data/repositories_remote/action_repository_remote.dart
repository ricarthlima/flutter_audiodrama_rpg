import 'dart:convert';

import '../repositories/action_repository.dart';
import '../../_core/helpers/print.dart';
import '../../domain/dto/action_template.dart';
import '../../domain/dto/list_action.dart';
import 'remote_mixin.dart';

class ActionRepositoryRemote extends ActionRepository
    with RemoteMixin<ListAction> {
  @override
  final String key = "actions";

  @override
  ListAction fromMap(Map<String, dynamic> map) {
    return ListAction.fromMap(map);
  }

  @override
  List<ListAction> getAll() => List.unmodifiable(cachedList);

  @override
  Future<void> onInitialize() async {
    String? jsonString = await remoteInitialize(populateMyself: true);
    if (jsonString != null) {
      printD("[POPULATING TO MEMORY] $key");
      Map<String, dynamic> jsonData = json.decode(jsonString);

      for (String key in jsonData.keys) {
        String name = key;
        bool isWork = (jsonData[key] as List<dynamic>).first["isWork"];
        List<ActionTemplate> listAc = (jsonData[key] as List<dynamic>)
            .map((e) => ActionTemplate.fromMap(e))
            .toList();
        cachedList.add(
          ListAction(name: name, isWork: isWork, listActions: listAc),
        );
      }

      printD("[POPULATED] $key");
    }
  }
}
