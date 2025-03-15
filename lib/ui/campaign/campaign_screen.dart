import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/components/campaign_appbar.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:provider/provider.dart';

import '../_core/app_colors.dart';
import '../_core/dimensions.dart';
import '../_core/widgets/named_widget.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CampaignViewModel>(context, listen: false).onInitialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);

    // TODO modularizar esse campanha nao encontrada
    return Scaffold(
      appBar: getCampaignAppBar(context),
      extendBodyBehindAppBar: true,
      body: (campaignVM.isLoading)
          ? Center(child: CircularProgressIndicator())
          : (campaignVM.campaign != null && campaignVM.isOwnerOrInvited)
              ? _buildBody()
              : Center(
                  child: Text(
                    "Campanha não encontrada.",
                  ),
                ),
    );
  }

  Widget _buildBody() {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);
    return Stack(
      children: [
        if (campaignVM.campaign!.imageBannerUrl != null)
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(175),
                  Colors.transparent,
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Image.network(
              campaignVM.campaign!.imageBannerUrl!,
              height: (isVertical(context)) ? 250 : 300,
              width: width(context),
              fit: BoxFit.fitWidth,
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 96, left: 32, right: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getNameWidget(campaignVM),
              Text(campaignVM.campaign!.description ?? ""),
            ],
          ),
        )
      ],
    );
  }

  NamedWidget _getNameWidget(CampaignViewModel campaignVM) {
    return NamedWidget(
      title: "Nome",
      isLeft: true,
      child: AnimatedSwitcher(
        duration: Duration(seconds: 1),
        child: (campaignVM.isEditing)
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width(context) * 0.8,
                  minWidth: width(context) * 0.2,
                ),
                child: IntrinsicWidth(
                  child: TextField(
                    controller: campaignVM.nameController,
                    style: TextStyle(
                      fontSize: isVertical(context) ? 18 : 48,
                      fontFamily: FontFamily.sourceSerif4,
                    ),
                  ),
                ),
              )
            : Text(
                campaignVM.campaign!.name ?? "Vamos adicionar um nome?",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isVertical(context) ? 18 : 48,
                  fontFamily: FontFamily.bungee,
                  color: AppColors.red,
                ),
              ),
      ),
    );
  }
}
