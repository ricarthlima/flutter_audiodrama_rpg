import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../_core/fonts.dart';
import '../view/campaign_visual_novel_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

void showTutorialServer(BuildContext context) {
  final ytController = YoutubePlayerController(
    params: YoutubePlayerParams(
      mute: false,
      showControls: true,
      showFullscreenButton: true,
      loop: true,
      interfaceLanguage: 'pt_BR',
      strictRelatedVideos: true,
      enableCaption: false,
    ),
  );

  ytController.cueVideoById(videoId: 'E3GTBctILw0');

  showDialog(
    context: context,
    builder: (context) {
      TextEditingController controller = TextEditingController(
        text: context.read<CampaignVisualNovelViewModel>().data.baseUrl,
      );
      bool isLoading = false;
      return StatefulBuilder(
        builder: (context, setState) {
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
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: YoutubePlayer(
                      controller: ytController,
                      aspectRatio: 16 / 9,
                    ),
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodySmall,

                      children: [
                        TextSpan(text: "Baixe os "),
                        TextSpan(
                          text: "arquivos auxiliares",
                          style: TextStyle(
                            color: AppColors.red,
                            decorationStyle: TextDecorationStyle.wavy,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                Uri.parse(
                                  'https://github.com/ricarthlima/adrpg_tools/releases',
                                ),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                        ),
                        TextSpan(text: " antes de começar."),
                      ],
                    ),
                  ),
                  Divider(thickness: 0.1),
                  TextFormField(
                    controller: controller,
                    decoration: InputDecoration(label: Text("Servidor")),
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
                                .then((value) {
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                });
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
        },
      );
    },
  );
}
