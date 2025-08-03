import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

int calculateVersionInt(String? version) {
  if (version == null) return 0;

  int result = 0;

  List<String> numberSplit = version.split(".");

  int i = 1;
  for (String numberStr in numberSplit) {
    if (int.tryParse(numberStr) != null) {
      result += int.parse(numberStr) * pow(10, i).toInt();
    }
    i++;
  }

  return result;
}

class NewsService {
  NewsService._();
  static final NewsService _instance = NewsService._();
  static NewsService get instance => _instance;

  static const String _key = "NEWEST_NEWS";

  Future<int> loadLocalNewest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  Future<void> saveNewest(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_key, value);
  }

  Future<NewsModel?> getNews() async {
    final packageInfo = await PackageInfo.fromPlatform();
    int localVersionInt = calculateVersionInt(packageInfo.version);

    int local = await loadLocalNewest();

    final query = await FirebaseFirestore.instance.collection("news").get();

    for (var doc in query.docs) {
      final news = NewsModel.fromMap(doc.data());
      if (news.versionInt > local && news.versionInt == localVersionInt) {
        return news;
      }
    }

    return null;
  }

  Future<void> writeNews(NewsModel news) async {
    return FirebaseFirestore.instance
        .collection("news")
        .doc(news.version)
        .set(news.toMap());
  }
}

class NewsModel {
  String version;
  String title;
  int versionInt;
  String description;
  DateTime createdAt;

  NewsModel({
    required this.version,
    required this.title,
    required this.versionInt,
    required this.description,
    required this.createdAt,
  });

  NewsModel copyWith({
    String? version,
    String? title,
    int? versionInt,
    String? description,
    DateTime? createdAt,
  }) {
    return NewsModel(
      version: version ?? this.version,
      title: title ?? this.title,
      versionInt: versionInt ?? this.versionInt,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'title': title,
      'versionInt': versionInt,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      version: map['version'] ?? '',
      title: map['title'] ?? '',
      versionInt: map['versionInt']?.toInt() ?? 0,
      description: map['description'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory NewsModel.fromJson(String source) =>
      NewsModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'NewsModel(version: $version, title: $title, versionInt: $versionInt, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NewsModel &&
        other.version == version &&
        other.title == title &&
        other.versionInt == versionInt &&
        other.description == description &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return version.hashCode ^
        title.hashCode ^
        versionInt.hashCode ^
        description.hashCode ^
        createdAt.hashCode;
  }
}
