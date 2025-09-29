import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:intl/intl.dart';

import '../../../data/services/news_service.dart';
import '../../_core/app_colors.dart';

void showNewsDialog(BuildContext context, NewsModel news) {
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
      color: Colors.black,
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
                    color: AppColors.red,
                  ),
                ),
                Text(
                  "versão ${widget.news.version} - ${DateFormat('dd/MM/yyyy - HH:mm', 'pt_BR').format(widget.news.createdAt)}",
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
                Divider(thickness: 0.25),
                Flexible(
                  child: Scrollbar(
                    controller: scrollController,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: MarkdownBody(
                        data: widget.news.description,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            fontFamily: "SourceSerif4",
                            color: Colors.white,
                          ),
                          strong: TextStyle(
                            fontFamily: "SourceSerif4",
                            color: AppColors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
