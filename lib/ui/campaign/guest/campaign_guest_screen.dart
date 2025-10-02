import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/router.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/utils/campaign_scenes.dart';
import 'package:go_router/go_router.dart';
import 'partials/campaign_guest_novel.dart';
import '../view/campaign_visual_novel_view_model.dart';
import 'package:provider/provider.dart';

import '../../../_core/providers/audio_provider.dart';
import '../../../data/services/campaign_roll_service.dart';
import '../../../domain/models/campaign_roll.dart';
import '../../../domain/models/campaign_visual.dart';
import '../../_core/components/movable_expandable_screen.dart';
import '../../_core/dimensions.dart';
import '../view/campaign_view_model.dart';

class CampaignGuestScreen extends StatefulWidget {
  final double sizeFactor;
  final bool isPreview;
  const CampaignGuestScreen({
    super.key,
    this.sizeFactor = 1.0,
    this.isPreview = false,
  });

  @override
  State<CampaignGuestScreen> createState() => _CampaignGuestScreenState();
}

class _CampaignGuestScreenState extends State<CampaignGuestScreen> {
  StreamSubscription? rollStreamSub;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CampaignProvider campaignVM = context.read<CampaignProvider>();
      AudioProvider audioProvider = context.read<AudioProvider>();
      CampaignRollService.instance
          .listen(campaignId: campaignVM.campaign!.id)
          .listen((QuerySnapshot<Map<String, dynamic>> event) {
            if (event.docChanges.isNotEmpty &&
                event.docChanges.length == 1 &&
                event.docChanges.first.doc.data() != null) {
              CampaignRoll roll = CampaignRoll.fromMap(
                event.docChanges.first.doc.data()!,
              );

              if (roll.userId != FirebaseAuth.instance.currentUser!.uid) {
                for (int i = 0; i < roll.rollLog.rolls.length; i++) {
                  audioProvider.playDice(i);
                }
              }
            }
          });
    });
    super.initState();
  }

  @override
  void dispose() {
    rollStreamSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campaignVM = context.watch<CampaignProvider>();
    final visualVM = context.watch<CampaignVisualNovelViewModel>();

    if (!campaignVM.isOwnerOrInvited) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Text("Campanha não encontrada."),
              ElevatedButton(
                onPressed: () {
                  context.go(AppRouter.home);
                },
                child: Text("Voltar"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: (isVertical(context))
              ? 16 / 9
              : width(context) / height(context),
          child: SizedBox(
            width: width(context),
            child: Stack(
              children:
                  <Widget>[
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: switch (campaignVM.campaign!.activeSceneType) {
                        CampaignScenes.preview => Placeholder(),
                        CampaignScenes.novel => CampaignGuestNovel(),
                        CampaignScenes.grid => Placeholder(),
                        CampaignScenes.cutscenes => Placeholder(),
                      },
                    ),
                  ] +
                  _generateListStack(context, visualVM) +
                  [
                    if (!widget.isPreview)
                      Align(
                        alignment: Alignment.center,
                        child: Stack(
                          children: visualVM.data.listObjects
                              .where((e) => e.isEnable)
                              .map(
                                (e) => MovableExpandableScreen(
                                  key: ValueKey(e.url),
                                  title: e.name,
                                  width: 600,
                                  child: Image.network(e.url),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _generateListStack(
    BuildContext context,
    CampaignVisualNovelViewModel visualVM,
  ) {
    List<Widget> result = [];
    List<Widget> leftList = [];

    double verticalScale = (isVertical(context)) ? 0.2 : 0.75;

    for (int i = 0; i < visualVM.data.listLeftActive.length; i++) {
      CampaignVisual cm = visualVM.data.listLeftActive[i];
      leftList.add(
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left:
                  visualVM.data.visualScale *
                  i *
                  visualVM.data.distanceFactor *
                  widget.sizeFactor,
            ),
            child: Image.network(
              cm.url,
              width:
                  visualVM.data.visualScale * widget.sizeFactor * verticalScale,
            ),
          ),
        ),
      );
    }

    List<Widget> rightList = [];
    for (int i = 0; i < visualVM.data.listRightActive.length; i++) {
      CampaignVisual cm = visualVM.data.listRightActive[i];
      rightList.add(
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(
              right:
                  visualVM.data.visualScale *
                  i *
                  visualVM.data.distanceFactor *
                  widget.sizeFactor,
            ),
            child: Transform.flip(
              flipX: true,
              child: Image.network(
                cm.url,
                width:
                    visualVM.data.visualScale *
                    widget.sizeFactor *
                    verticalScale,
              ),
            ),
          ),
        ),
      );
    }
    leftList = leftList.reversed.toList();
    rightList = rightList.reversed.toList();
    result.addAll(leftList);
    result.addAll(rightList);

    return result;
  }
}
