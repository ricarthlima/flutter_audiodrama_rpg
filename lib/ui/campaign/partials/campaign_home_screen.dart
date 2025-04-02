import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_visual.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_visual_novel_view_model.dart';
import 'package:provider/provider.dart';

class CampaignHomeScreen extends StatelessWidget {
  const CampaignHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);

    if (campaignVM.isOwner && campaignVM.isEditing) {
      return _CampaignHomeOwner();
    }

    return _CampaignHomeGuest();
  }
}

class _CampaignHomeGuest extends StatelessWidget {
  final double sizeFactor;
  const _CampaignHomeGuest({this.sizeFactor = 1.0});

  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: _generateListStack(context, visualVM),
        ),
      ),
    );
  }

  List<Widget> _generateListStack(
      BuildContext context, CampaignVisualNovelViewModel visualVM) {
    List<Widget> result = [];
    if (visualVM.backgroundActive != null) {
      result.add(
        Align(
          alignment: Alignment.bottomCenter,
          child: Image.network(
            visualVM.backgroundActive!.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    for (int i = visualVM.listLeftActive.length - 1; i >= 0; i--) {
      CampaignVisual cm = visualVM.listLeftActive[i];
      result.add(
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: (width(context) / 6 * i).toDouble() * sizeFactor,
            ),
            child: Image.network(
              cm.imageUrl,
              width: width(context) / 5 * sizeFactor,
            ),
          ),
        ),
      );
    }

    for (int i = visualVM.listLeftActive.length - 1; i >= 0; i--) {
      CampaignVisual cm = visualVM.listRightActive[i];
      result.add(
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(
              right: (width(context) / 8 * i).toDouble() * sizeFactor,
            ),
            child: Image.network(
              cm.imageUrl,
              width: width(context) / 5 * sizeFactor,
            ),
          ),
        ),
      );
    }

    return result;
  }
}

class _CampaignHomeOwner extends StatelessWidget {
  const _CampaignHomeOwner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width(context),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(flex: 3, child: Container()),
              Flexible(
                flex: 6,
                child: SizedBox(
                  width: width(context) * 0.5,
                  child: _CampaignHomeGuest(
                    sizeFactor: 0.5,
                  ),
                ),
              ),
              Flexible(flex: 3, child: Container()),
            ],
          ),
          Container(),
        ],
      ),
    );
  }
}
