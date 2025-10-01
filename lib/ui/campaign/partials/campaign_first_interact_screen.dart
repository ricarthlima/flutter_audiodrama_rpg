import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../_core/providers/user_provider.dart';
import '../../../router.dart';
import '../../_core/app_colors.dart';
import '../../_core/dimensions.dart';
import '../../_core/fonts.dart';
import '../../home/utils/home_tabs.dart';
import '../view/campaign_view_model.dart';

class CampaignFirstInteractScreen extends StatefulWidget {
  const CampaignFirstInteractScreen({super.key});

  @override
  State<CampaignFirstInteractScreen> createState() =>
      _CampaignFirstInteractScreenState();
}

class _CampaignFirstInteractScreenState
    extends State<CampaignFirstInteractScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    CampaignProvider campaignVM = Provider.of<CampaignProvider>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return Stack(
      children: [
        if (campaignVM.campaign!.imageBannerUrl != null)
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withAlpha(100), Colors.transparent],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Image.network(
              campaignVM.campaign!.imageBannerUrl!,
              height: height(context),
              width: width(context),
              fit: BoxFit.cover,
            ),
          ),
        SizedBox(
          width: width(context),
          height: height(context),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  campaignVM.campaign!.name ?? "Sem nome",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isVertical(context) ? 18 : 48,
                    fontFamily: FontFamily.bungee,
                    color: AppColors.red,
                  ),
                ),
                Text(
                  campaignVM.campaign!.description == null ||
                          campaignVM.campaign!.description == ""
                      ? "Clique para entrar na campanha"
                      : campaignVM.campaign!.description!,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 32),
                if (!isLoading)
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                      });
                      campaignVM.hasInteracted = true;
                      userProvider.playCampaignAudios(campaignVM.campaign!);
                    },
                    child: Text("Entrar na campanha"),
                  ),
                if (isLoading) CircularProgressIndicator(),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                AppRouter().goHome(
                  context: context,
                  subPage: HomeTabs.campaigns,
                );
              },
              icon: Icon(Icons.arrow_back),
            ),
          ),
        ),
      ],
    );
  }
}
