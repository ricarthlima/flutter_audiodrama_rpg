// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

enum CampaignVisualType {
  portrait,
  background,
  music,
  ambience,
  sfx,
  objects,
}

class CampaignVisual {
  String name;
  String url;
  bool isEnable;
  CampaignVisualType type;

  CampaignVisual.fromUrl({
    required this.url,
    required this.type,
    this.isEnable = false,
  }) : name = url.substring(0).split("/").last.split(".").first;

  CampaignVisual({
    required this.name,
    required this.url,
    required this.type,
    required this.isEnable,
  });

  CampaignVisual copyWith({
    String? name,
    String? url,
    bool? isEnable,
    CampaignVisualType? type,
  }) {
    return CampaignVisual(
      name: name ?? this.name,
      url: url ?? this.url,
      type: type ?? this.type,
      isEnable: isEnable ?? this.isEnable,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'url': url,
      'type': type.name,
      'isEnable': isEnable,
    };
  }

  factory CampaignVisual.fromMap(Map<String, dynamic> map) {
    return CampaignVisual(
        name: map['name'] as String,
        url: map['url'] as String,
        isEnable: map['isEnable'] ?? false,
        type: CampaignVisualType.values
            .where((e) => e.name == map['type'] as String)
            .first);
  }

  String toJson() => json.encode(toMap());

  factory CampaignVisual.fromJson(String source) =>
      CampaignVisual.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CampaignVisual(name: $name, url: $url)';

  @override
  bool operator ==(covariant CampaignVisual other) {
    if (identical(this, other)) return true;

    return other.name == name && other.url == url;
  }

  @override
  int get hashCode => name.hashCode ^ url.hashCode;
}
