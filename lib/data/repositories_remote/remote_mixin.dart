import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import '../../_core/helpers/print.dart';

abstract class FromMap {
  FromMap.fromMap(Map<String, dynamic> map);
}

abstract mixin class RemoteMixin<T extends FromMap> {
  List<T> cachedList = [];
  T fromMap(Map<String, dynamic> map);

  String get key;

  Future<String?> remoteInitialize({bool populateMyself = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? version = prefs.getInt(key);

    bool needToUpdate = false;
    if (version != null) {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection("versions")
          .doc(key)
          .get();

      if (doc.exists && doc.data() != null) {
        int versionRemote = doc.data()!["version"];
        if (versionRemote > version) {
          needToUpdate = true;
        }
      }
    } else {
      needToUpdate = true;
    }

    String jsonStr = "";

    if (needToUpdate) {
      jsonStr = await _getAndSave(key: key);
    } else {
      String? result = await _getFromLocal(key);
      if (result != null) {
        jsonStr = result;
      } else {
        jsonStr = await _getAndSave(key: key);
      }
    }

    if (!populateMyself) {
      _cacheJson(jsonStr, key);
      return null;
    }

    return jsonStr;
  }

  Future<String> _getAndSave({required String key}) async {
    printD("[DOWNLOAD FROM SERVER] $key");

    // 1) versão remota
    final doc = await FirebaseFirestore.instance
        .collection("versions")
        .doc(key)
        .get();
    final int remoteVersion = (doc.data()?["version"] as int?) ?? 0;

    // 2) baixar JSON do Storage
    final ref = FirebaseStorage.instance.ref();
    final path = ref.child('sheets/$key.json');
    String url = await path.getDownloadURL();
    final response = await http.get(Uri.parse(url));
    String jsonStr = response.body;

    printD("[DOWNLOADED] $key");

    // 3) persistir local (Hive) e versão (SharedPreferences)
    printD("[SAVING LOCAL] $key");
    await Hive.openBox('cache');
    final box = Hive.box('cache');
    await box.put(key, jsonStr);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, remoteVersion);

    await Hive.close();
    printD("[SAVED LOCAL] $key");

    return jsonStr;
  }

  Future<String?> _getFromLocal(String key) async {
    printD("[LOAD LOCAL] $key");
    await Hive.openBox('cache');
    final box = Hive.box('cache');
    final String? s = box.get(key) as String?;
    await Hive.close();
    printD("[LOADED] $key");
    return s;
  }

  void _cacheJson(String jsonStr, String key) {
    printD("[POPULATING TO MEMORY] $key");
    final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
    cachedList = [];

    for (dynamic item in raw) {
      cachedList.add(fromMap(item));
    }

    printD("[POPULATED] $key");
  }
}
