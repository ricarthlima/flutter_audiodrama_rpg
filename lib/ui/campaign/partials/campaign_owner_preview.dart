import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../campaign_guest_screen.dart';

class CampaignOwnerPreview extends StatelessWidget {
  const CampaignOwnerPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final campaignVM = context.watch<CampaignProvider>();
    return Stack(
      children: [
        CampaignGuestScreen(isPreview: true),
        Align(
          alignment: Alignment.topRight,
          child: Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton.filled(
                onPressed: () {
                  campaignVM.isPreviewVisible = true;
                },
                icon: Icon(Icons.open_in_browser),
              ),
              if (kIsWeb)
                IconButton.filled(
                  onPressed: () {
                    launchUrl(
                      Uri.parse("${GoRouter.of(context).state.uri}/preview"),
                    );
                  },
                  icon: Icon(Icons.open_in_new),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
