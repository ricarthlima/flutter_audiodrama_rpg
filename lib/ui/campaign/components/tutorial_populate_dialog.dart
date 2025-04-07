import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/yt_html.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_visual_novel_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

showTutorialGitHub(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController controller = TextEditingController();
      return Dialog(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Text(
                "Popular com o GitHub",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: FontFamily.bungee,
                ),
              ),
              if (kIsWeb)
                SizedBox(
                  width: 200,
                  height: 200,
                  child: YouTubeEmbedWebOnly(),
                ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Como popular?"),
                    TextButton(
                      onPressed: () {
                        launchUrl(
                          Uri.parse(
                              'https://www.youtube.com/watch?v=MMEyqWeJ52Y'),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Text("Assista o tutorial."),
                    ),
                  ],
                ),
              ),
              Divider(thickness: 0.1),
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  label: Text("Url do GitHub"),
                  hintText: "https://github.com/username/reponame",
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context
                      .read<CampaignVisualNovelViewModel>()
                      .onPopulate(controller.text)
                      .then(
                    (value) {
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                  );
                },
                child: Text("Popular"),
              ),
            ],
          ),
        ),
      );
    },
  );
}
