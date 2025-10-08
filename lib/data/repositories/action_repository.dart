import 'package:flutter_rpg_audiodrama/_core/helpers/important_actions.dart';

import '../../domain/dto/action_template.dart';
import '../../domain/dto/list_action.dart';
import '../../domain/models/action_value.dart';

abstract class ActionRepository {
  Future<void> onInitialize();

  List<ListAction> getAll();

  ActionTemplate? getActionById(String id) {
    List<ActionTemplate> query = getAllActions()
        .where((element) => element.id == id)
        .toList();

    if (query.isNotEmpty) {
      return query[0];
    }

    return null;
  }

  List<ActionTemplate> getAllActions() {
    return getAll().expand((e) => e.listActions).toList();
  }

  bool isOnlyFreeOrPreparation(String id) {
    bool result = false;
    ActionTemplate? action = getActionById(id);

    if (action != null) {
      if ((action.isFree || action.isPreparation) &&
          !action.isReaction &&
          !action.isResisted) {
        result = true;
      }
    }

    return result;
  }

  bool isLuckAction(String id) {
    return id == ImportantActions.luck;
  }

  List<ActionTemplate> getListActionsFromActionValues({
    required List<ActionValue> listAV,
    required bool isWork,
  }) {
    List<ActionTemplate> result = [];

    List<String> listIds = listAV.map((e) => e.actionId).toList();

    for (String id in listIds) {
      ActionTemplate action = getActionById(id)!;
      if (action.isWork == isWork) {
        result.add(action);
      }
    }

    return result;
  }

  List<ListAction> getListWorks() {
    return getAll().where((e) => e.isWork == true).toList();
  }

  List<ActionTemplate> getActionsByGroupName(String typeId) {
    return getAll().where((e) => e.name == typeId).first.listActions;
  }

  List<ActionTemplate> getBasics() {
    return getListActionByGroupName("basic").listActions;
  }

  List<ActionTemplate> getMovement() {
    return getListActionByGroupName("movement").listActions;
  }

  List<ActionTemplate> getResisted() {
    return getListActionByGroupName("resisted").listActions;
  }

  List<ActionTemplate> getStrength() {
    return getListActionByGroupName("strength").listActions;
  }

  List<ActionTemplate> getAgility() {
    return getListActionByGroupName("agility").listActions;
  }

  List<ActionTemplate> getIntellect() {
    return getListActionByGroupName("intellect").listActions;
  }

  List<ActionTemplate> getSocial() {
    return getListActionByGroupName("social").listActions;
  }

  ListAction getListActionByGroupName(String groupName) {
    return getAll().where((e) => e.name == groupName).first;
  }
}
