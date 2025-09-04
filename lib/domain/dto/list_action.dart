import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../data/repositories_remote/remote_mixin.dart';
import 'action_template.dart';

class ListAction implements FromMap {
  String name;
  bool isWork;
  List<ActionTemplate> listActions;

  ListAction({
    required this.name,
    required this.isWork,
    required this.listActions,
  });

  ListAction copyWith({
    String? name,
    bool? isWork,
    List<ActionTemplate>? listActions,
  }) {
    return ListAction(
      name: name ?? this.name,
      isWork: isWork ?? this.isWork,
      listActions: listActions ?? this.listActions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isWork': isWork,
      'listActions': listActions.map((x) => x.toMap()).toList(),
    };
  }

  factory ListAction.fromMap(Map<String, dynamic> map) {
    return ListAction(
      name: map['name'] ?? '',
      isWork: map['isWork'] ?? false,
      listActions: List<ActionTemplate>.from(
        map['listActions']?.map((x) => ActionTemplate.fromMap(x)),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ListAction.fromJson(String source) =>
      ListAction.fromMap(json.decode(source));

  @override
  String toString() =>
      'ListAction(name: $name, isWork: $isWork, listActions: $listActions)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ListAction &&
        other.name == name &&
        other.isWork == isWork &&
        listEquals(other.listActions, listActions);
  }

  @override
  int get hashCode => name.hashCode ^ isWork.hashCode ^ listActions.hashCode;
}
