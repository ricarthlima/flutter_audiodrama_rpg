import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/user_provider.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/components/campaign_appbar.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/components/campaign_drawer.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/partials/campaign_sheets_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/utils/campaign_subpages.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:provider/provider.dart';

import '../_core/app_colors.dart';
import '../_core/dimensions.dart';
import '../_core/widgets/named_widget.dart';

class CampaignScreen extends StatefulWidget {
  final CampaignSubPages subPage;
  const CampaignScreen({
    super.key,
    this.subPage = CampaignSubPages.sheets,
  });

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(
        context,
        listen: false,
      );
      campaignVM.onInitialize();
      campaignVM.currentPage = widget.subPage;

      Provider.of<UserProvider>(context, listen: false).onInitialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);

    // TODO modularizar esse campanha nao encontrada
    return Scaffold(
      appBar: getCampaignAppBar(
        context: context,
        campaignVM: campaignVM,
      ),
      extendBodyBehindAppBar: true,
      body: (campaignVM.isLoading)
          ? Center(child: CircularProgressIndicator())
          : (campaignVM.campaign != null && campaignVM.isOwnerOrInvited)
              ? _buildBodyWithDrawer()
              : Center(
                  child: Text(
                    "Campanha não encontrada.",
                  ),
                ),
    );
  }

  Widget _buildBodyWithDrawer() {
    return Stack(
      children: [
        _buildBody(),
        Align(
          alignment: Alignment.bottomRight,
          child: SizedBox(
            height: height(context) - 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                VerticalDivider(
                  thickness: 0.1,
                  indent: 0,
                  endIndent: 0,
                ),
                CampaignDrawer(),
              ],
            ),
          ),
        ),
      ],
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
          padding: const EdgeInsets.only(top: 72, left: 32, right: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getNameWidget(campaignVM),
              Text(campaignVM.campaign!.description ?? ""),
              SizedBox(
                height: 64,
                width: width(context) * 0.75,
                child: Divider(
                  thickness: 0.5,
                ),
              ),
              SizedBox(
                width: width(context) - 100,
                child: IndexedStack(
                  index:
                      CampaignSubPages.values.indexOf(campaignVM.currentPage),
                  children: [
                    // Sheets
                    CampaignSheetsScreen(),
                  ],
                ),
              )
            ],
          ),
        ),
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
