import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../../_core/app_colors.dart';
import '../../_core/dimensions.dart';
import '../../_core/fonts.dart';
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
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return Stack(
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withAlpha(100),
                Colors.transparent,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: Image.network(
            campaignVM.campaign!.imageBannerUrl!,
            height: 400,
            width: width(context),
            fit: BoxFit.fitWidth,
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
                  campaignVM.campaign!.name ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isVertical(context) ? 18 : 48,
                    fontFamily: FontFamily.bungee,
                    color: AppColors.red,
                  ),
                ),
                Text(
                  campaignVM.campaign!.description ?? "...",
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
                      userProvider.playCampaignAudios(
                        campaignVM.campaign!,
                        context,
                      );
                    },
                    child: Text("Entrar na campanha"),
                  ),
                if (isLoading) CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
