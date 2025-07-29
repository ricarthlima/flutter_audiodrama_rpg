import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../_core/fonts.dart';
import '../../_core/yt_html.dart';
import '../view/campaign_visual_novel_view_model.dart';
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
                      .onPopulate(
                        url: controller.text,
                        type: PopulateType.github,
                      )
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

showTutorialServer(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController controller = TextEditingController();
      bool isLoading = false;
      return StatefulBuilder(builder: (context, setState) {
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
                  "Popular do servidor",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: FontFamily.bungee,
                  ),
                ),
                if (kIsWeb)
                  SizedBox(
                    width: 200,
                    height: 200,
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
                    label: Text("Servidor:Porta"),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() => isLoading = true);
                          context
                              .read<CampaignVisualNovelViewModel>()
                              .onPopulate(
                                url: controller.text,
                                type: PopulateType.server,
                              )
                              .then(
                            (value) {
                              if (!context.mounted) return;
                              Navigator.pop(context);
                            },
                          );
                        },
                  child: !isLoading
                      ? Text("Popular")
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
      });
    },
  );
}
