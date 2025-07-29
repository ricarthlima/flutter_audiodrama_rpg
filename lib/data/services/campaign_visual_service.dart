import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../_core/release_mode.dart';
import '../../domain/models/campaign_vm_model.dart';
import 'package:http/http.dart' as http;

class CampaignVisualService {
  CampaignVisualService._();
  static final CampaignVisualService _instance = CampaignVisualService._();
  static CampaignVisualService get instance => _instance;

  final subFolders = [
    'ambiences',
    'musics',
    'backgrounds',
    'portraits',
    'sfxs',
    'objects',
    'maps',
    'tokens',
  ];

  Future<Map<String, List<String>>> populateFromServer({
    required String baseUrl,
  }) async {
    if (baseUrl.endsWith("/")) {
      baseUrl = baseUrl.substring(0, baseUrl.length);
    }
    final uri = Uri.parse('$baseUrl/list.json');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar a lista de arquivos');
    }

    final List decoded = json.decode(response.body);
    final allPaths = decoded.cast<String>();

    final result = <String, List<String>>{
      for (final folder in subFolders) folder: [],
    };

    for (final path in allPaths) {
      for (final folder in subFolders) {
        if (path.startsWith('$folder/')) {
          result[folder]!.add('$baseUrl/$path');
          break;
        }
      }
    }

    return result;
  }

  Future<Map<String, List<String>>> populateFromGitHub({
    required String repoUrl,
  }) async {
    final uri = Uri.parse(repoUrl);
    final parts = uri.pathSegments;

    if (parts.length < 2) throw Exception('URL inválida do repositório');

    final owner = parts[0];
    final repo = parts[1];
    final branch = 'main'; // ou 'master' dependendo do repositório

    final result = <String, List<String>>{};

    for (final folder in subFolders) {
      final apiUrl = Uri.https(
        'api.github.com',
        '/repos/$owner/$repo/contents/$folder',
        {'ref': branch},
      );

      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        final List decoded = json.decode(response.body);
        final urls = decoded
            .where((item) => item['type'] == 'file')
            .map<String>((item) => item['download_url'] as String)
            .toList();
        result[folder] = urls;
      } else {
        result[folder] = [];
      }
    }

    return result;
  }

  Future<void> onSave({
    required String campaignId,
    required CampaignVisualDataModel data,
  }) async {
    await FirebaseFirestore.instance
        .collection("${releaseCollection}campaigns")
        .doc(campaignId)
        .update(
      {
        "visualData": data.toMap(),
      },
    );
  }

  Future<void> onRemoveAll({
    required String campaignId,
  }) async {
    await FirebaseFirestore.instance
        .collection("${releaseCollection}campaigns")
        .doc(campaignId)
        .update(
      {
        "visualData": null,
      },
    );
  }
}
