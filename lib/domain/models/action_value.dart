import 'dart:convert';

class ActionValue {
  String actionId;
  int value;

  ActionValue({
    required this.actionId,
    required this.value,
  });

  ActionValue copyWith({
    String? actionId,
    int? value,
  }) {
    return ActionValue(
      actionId: actionId ?? this.actionId,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'actionId': actionId,
      'value': value,
    };
  }

  factory ActionValue.fromMap(Map<String, dynamic> map) {
    return ActionValue(
      actionId: map['actionId'] as String,
      value: map['value'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ActionValue.fromJson(String source) =>
      ActionValue.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ActionValue(actionId: $actionId, value: $value)';

  @override
  bool operator ==(covariant ActionValue other) {
    if (identical(this, other)) return true;

    return other.actionId == actionId && other.value == value;
  }

  @override
  int get hashCode => actionId.hashCode ^ value.hashCode;
}
