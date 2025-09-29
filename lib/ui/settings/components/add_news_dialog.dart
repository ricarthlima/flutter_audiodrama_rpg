import 'package:flutter/material.dart';
import '../../../data/services/news_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

void showAddNewsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(child: _AddNewsDialog()),
  );
}

class _AddNewsDialog extends StatefulWidget {
  const _AddNewsDialog();

  @override
  State<_AddNewsDialog> createState() => __AddNewsDialogState();
}

class __AddNewsDialogState extends State<_AddNewsDialog> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  PackageInfo? info;

  bool isLoading = false;

  @override
  void initState() {
    loadInfos();
    super.initState();
  }

  Future<void> loadInfos() async {
    info = await PackageInfo.fromPlatform();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Escrever notas de atualização",
              style: TextStyle(fontSize: 24, fontFamily: "Bungee"),
            ),
            TextFormField(
              controller: titleController,
              maxLength: 30,
              decoration: InputDecoration(label: Text("Título")),
            ),
            TextFormField(
              controller: descriptionController,
              maxLines: null,
              decoration: InputDecoration(label: Text("Descrição")),
            ),
            Text("Data: ${DateTime.now()}"),
            Text("Versão: ${info?.version}"),
            Text("Versão int: ${calculateVersionInt(info?.version)}"),
            ElevatedButton(
              onPressed: (!isLoading)
                  ? () {
                      onSend();
                    }
                  : null,
              child: (!isLoading)
                  ? Text("Enviar")
                  : SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void onSend() async {
    if (info != null && !isLoading) {
      setState(() {
        isLoading;
      });
      NewsModel news = NewsModel(
        version: info!.version,
        title: titleController.text,
        versionInt: calculateVersionInt(info!.version),
        description: descriptionController.text,
        createdAt: DateTime.now(),
      );
      await NewsService.instance.writeNews(news);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
