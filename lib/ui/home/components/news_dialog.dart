import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/services/news_service.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/text_markdown.dart';

showNewsDialog(BuildContext context, NewsModel news) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(child: _NewsDialog(news: news));
    },
  );
}

class _NewsDialog extends StatefulWidget {
  final NewsModel news;
  const _NewsDialog({required this.news});

  @override
  State<_NewsDialog> createState() => _NewsDialogState();
}

class _NewsDialogState extends State<_NewsDialog> {
  ScrollController scrollController = ScrollController();
  bool isSave = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 600,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.news.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: "Bungee",
                  ),
                ),
                Text(
                  "versão ${widget.news.version}",
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
                Divider(thickness: 0.25),
                Flexible(
                  child: Scrollbar(
                    controller: scrollController,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: TextMarkdown(widget.news.description),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            spacing: 8,
            children: [
              SizedBox(height: 0),
              CheckboxListTile(
                value: isSave,
                title: Text("Não ver novamente nesta versão."),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  setState(() {
                    isSave = !isSave;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  onExit();
                },
                child: Text("Fechar"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void onExit() async {
    if (isSave) {
      NewsService.instance.saveNewest(widget.news.versionInt);
    }
    Navigator.pop(context);
  }
}
