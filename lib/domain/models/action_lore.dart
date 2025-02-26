// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ActionLore {
  String actionId;
  String loreText;
  ActionLore({
    required this.actionId,
    required this.loreText,
  });

  ActionLore copyWith({
    String? actionId,
    String? loreText,
  }) {
    return ActionLore(
      actionId: actionId ?? this.actionId,
      loreText: loreText ?? this.loreText,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'actionId': actionId,
      'loreText': loreText,
    };
  }

  factory ActionLore.fromMap(Map<String, dynamic> map) {
    return ActionLore(
      actionId: map['actionId'] as String,
      loreText: map['loreText'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ActionLore.fromJson(String source) =>
      ActionLore.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ActionLore(actionId: $actionId, loreText: $loreText)';

  @override
  bool operator ==(covariant ActionLore other) {
    if (identical(this, other)) return true;

    return other.actionId == actionId && other.loreText == loreText;
  }

  @override
  int get hashCode => actionId.hashCode ^ loreText.hashCode;
}
