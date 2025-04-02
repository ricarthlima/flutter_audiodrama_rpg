// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CampaignVisual {
  String name;
  String imageUrl;
  bool isBackground;

  CampaignVisual({
    required this.name,
    required this.imageUrl,
    required this.isBackground,
  });

  CampaignVisual copyWith({
    String? name,
    String? imageUrl,
    bool? isBackground,
  }) {
    return CampaignVisual(
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      isBackground: isBackground ?? this.isBackground,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'imageUrl': imageUrl,
      'isBackground': isBackground,
    };
  }

  factory CampaignVisual.fromMap(Map<String, dynamic> map) {
    return CampaignVisual(
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String,
      isBackground: map['isBackground'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory CampaignVisual.fromJson(String source) =>
      CampaignVisual.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CampaignVisual(name: $name, imageUrl: $imageUrl, isBackground: $isBackground)';

  @override
  bool operator ==(covariant CampaignVisual other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.imageUrl == imageUrl &&
        other.isBackground == isBackground;
  }

  @override
  int get hashCode => name.hashCode ^ imageUrl.hashCode ^ isBackground.hashCode;
}
