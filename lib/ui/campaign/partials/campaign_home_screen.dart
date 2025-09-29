import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/services/campaign_roll_service.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_roll.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/components/movable_expandable_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/vertical_split_view.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign_battle_map/sections/campaign_grid_guest.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign_battle_map/sections/campaign_grid_owner.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/utils/campaign_scenes.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/widgets/list_settings.dart';
import '../../../_core/providers/audio_provider.dart';
import '../../../domain/models/campaign_visual.dart';
import '../../_core/app_colors.dart';
import '../../_core/components/image_dialog.dart';
import '../../_core/dimensions.dart';
import '../../_core/fonts.dart';
import '../../_core/widgets/generic_filter_widget.dart';
import '../components/tutorial_populate_dialog.dart';
import '../view/campaign_view_model.dart';
import '../view/campaign_visual_novel_view_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../../_core/providers/user_provider.dart';

class CampaignHomeScreen extends StatefulWidget {
  const CampaignHomeScreen({super.key});

  @override
  State<CampaignHomeScreen> createState() => _CampaignHomeScreenState();
}

class _CampaignHomeScreenState extends State<CampaignHomeScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CampaignProvider campaignVM = Provider.of<CampaignProvider>(
        context,
        listen: false,
      );
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).playCampaignAudios(campaignVM.campaign!, context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CampaignProvider campaignVM = Provider.of<CampaignProvider>(context);

    if (campaignVM.isOwner) {
      return _CampaignRouterOwner();
    }

    return _CampaignRouterGuest();
  }
}

class _CampaignRouterGuest extends StatelessWidget {
  const _CampaignRouterGuest();

  @override
  Widget build(BuildContext context) {
    return CampaignGridGuest();
  }
}

class _CampaignVisualGuest extends StatefulWidget {
  final double sizeFactor;
  final bool isPreview;
  const _CampaignVisualGuest({this.sizeFactor = 1.0, this.isPreview = false});

  @override
  State<_CampaignVisualGuest> createState() => _CampaignVisualGuestState();
}

class _CampaignVisualGuestState extends State<_CampaignVisualGuest> {
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
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);
    return InteractiveViewer(
      transformationController:
          (!visualVM.data.allowPan && !visualVM.data.allowZoom)
          ? TransformationController(Matrix4.identity())
          : null,
      panEnabled: visualVM.data.allowPan,
      scaleEnabled: visualVM.data.allowZoom,
      maxScale: 10,
      child: Center(
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
                      child: AnimatedSwitcher(
                        duration: Duration(
                          milliseconds: visualVM
                              .data
                              .transitionBackgroundDurationInMilliseconds,
                        ),
                        child: (visualVM.data.backgroundActive == null)
                            ? Container(
                                key: ValueKey('empty'),
                                color: Colors.black,
                              )
                            : Image.network(
                                visualVM.data.backgroundActive!.url,
                                key: ValueKey(
                                  visualVM.data.backgroundActive!.url,
                                ),
                                fit: BoxFit.fitWidth,
                                width: width(context),
                                height: height(context),
                              ),
                      ),
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

class _CampaignRouterOwner extends StatelessWidget {
  const _CampaignRouterOwner();

  @override
  Widget build(BuildContext context) {
    return _CampaignVisualOwner();
  }
}

class _CampaignOwnerEmpty extends StatelessWidget {
  const _CampaignOwnerEmpty();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          Text(
            "Mesa de Ambientação",
            style: TextStyle(fontSize: 22, fontFamily: FontFamily.bungee),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  showTutorialServer(context);
                },
                icon: Icon(Icons.podcasts),
                label: Text("Popular do servidor"),
              ),
            ],
          ),
          Opacity(
            opacity: 0.7,
            child: Text(
              "Utilize uma das opções acima para popular sua mesa de ambientação.",
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignVisualOwner extends StatelessWidget {
  const _CampaignVisualOwner();

  @override
  Widget build(BuildContext context) {
    final campaignVM = context.watch<CampaignProvider>();
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);

    if (visualVM.isEmpty) {
      return _CampaignOwnerEmpty();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 96, bottom: 16),
      child: SizedBox(
        width: width(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            ListSettings(),
            Expanded(
              child: VerticalSplitView(
                initialRatio: 0.75,
                minRatio: 0.2,
                maxRatio: 0.9,
                dividerThickness: 4,
                spacing: 10,
                dragSensitivity: 10,
                top: switch (campaignVM.campaignScene) {
                  CampaignScenes.visual => CampaignVisualOwner(
                    visualVM: visualVM,
                  ),
                  CampaignScenes.grid => CampaignGridOwner(),
                },

                bottom: _RowGroups(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CampaignVisualOwner extends StatelessWidget {
  const CampaignVisualOwner({super.key, required this.visualVM});

  final CampaignVisualNovelViewModel visualVM;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Flexible(flex: 2, fit: FlexFit.tight, child: _ListCharactersVisual()),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _CampaignVisualGuest(
                    sizeFactor: 300 / height(context),
                    isPreview: true,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                IntrinsicWidth(
                  child: CheckboxListTile(
                    value: visualVM.data.allowPan,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text("Mover"),
                    onChanged: (value) {
                      visualVM.togglePan();
                    },
                  ),
                ),
                IntrinsicWidth(
                  child: CheckboxListTile(
                    value: visualVM.data.allowZoom,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text("Zoom"),
                    onChanged: (value) {
                      visualVM.toggleZoom();
                    },
                  ),
                ),
                IntrinsicWidth(
                  child: CheckboxListTile(
                    value: visualVM.isClearZoomAndPan,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text("Centralizar ao mudar"),
                    onChanged: (value) {
                      visualVM.isClearZoomAndPan = !visualVM.isClearZoomAndPan;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: _ListCharactersVisual(isRight: true),
        ),
      ],
    );
  }
}

class _ListCharactersVisual extends StatelessWidget {
  final bool isRight;
  _ListCharactersVisual({this.isRight = false});

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isRight)
          Text(
            "Personagens da Esquerda",
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: FontFamily.bungee),
          ),
        if (isRight)
          Text(
            "Personagens da Direita",
            style: TextStyle(fontFamily: FontFamily.bungee),
          ),
        CheckboxListTile(
          value: (isRight) ? visualVM.isClearRight : visualVM.isClearLeft,
          contentPadding: EdgeInsets.zero,
          controlAffinity: (isRight)
              ? ListTileControlAffinity.leading
              : ListTileControlAffinity.trailing,
          onChanged: (value) {
            if (isRight) {
              visualVM.isClearRight = !visualVM.isClearRight;
            } else {
              visualVM.isClearLeft = !visualVM.isClearLeft;
            }
          },
          title: Text(
            "Limpar ao mudar fundo",
            textAlign: (!isRight) ? TextAlign.end : TextAlign.start,
          ),
        ),
        Flexible(
          child: MasonryGridView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(right: 16),
            gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120, // largura máxima por item
            ),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: visualVM.data.listPortraits.length,
            itemBuilder: (context, index) {
              CampaignVisual cv = visualVM.data.listPortraits[index];
              return _ImageVisualItem(visual: cv, isRight: isRight);
            },
          ),
        ),
      ],
    );
  }
}

class _ImageVisualItem extends StatelessWidget {
  final CampaignVisual visual;
  final bool isRight;

  const _ImageVisualItem({required this.visual, required this.isRight});

  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);
    return InkWell(
      onTap: () {
        visualVM.toggleVisual(isRight: isRight, visual: visual);
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: visualVM.isVisualInList(isRight: isRight, visual: visual)
              ? Border.all(width: 4, color: AppColors.red)
              : Border.all(width: 4, color: Colors.transparent),
        ),
        child: Stack(
          children: [
            CachedNetworkImage(imageUrl: visual.url, width: 100),
            IconViewImageButton(imageUrl: visual.url),
            Align(
              alignment: Alignment.bottomCenter,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withAlpha(175), Colors.transparent],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Container(
                  height: 25,
                  width: 100,
                  color: Colors.black,
                  child: Text(" "),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                visual.name,
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowGroups extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Flexible(
          flex: 3,
          fit: FlexFit.tight,
          child: _ImageAreaWidget(
            title: "Cenários",
            listImages: visualVM.data.listBackgrounds,
            childWidth: 200,
            showTitle: true,
            aspectRatio: 16 / 9,
            onTap: visualVM.toggleBackground,
          ),
        ),
        Flexible(
          flex: 3,
          fit: FlexFit.tight,
          child: _ImageAreaWidget(
            title: "Objetos, Notas e Itens",
            listImages: visualVM.data.listObjects,
            childWidth: 64,
            aspectRatio: 1,
            onTap: visualVM.toggleObject,
          ),
        ),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: _AudioAreaWidget(
            title: "Músicas",
            type: AudioProviderType.music,
            listAudios: visualVM.data.listMusics,
          ),
        ),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: _AudioAreaWidget(
            title: "Ambientações",
            type: AudioProviderType.ambience,
            listAudios: visualVM.data.listAmbiences,
          ),
        ),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: _AudioAreaWidget(
            title: "Efeitos",
            type: AudioProviderType.sfx,
            listAudios: visualVM.data.listSfxs,
          ),
        ),
      ],
    );
  }
}

class _ImageAreaWidget extends StatefulWidget {
  final String title;
  final List<CampaignVisual> listImages;
  final double childWidth;
  final double aspectRatio;
  final Function(CampaignVisual object) onTap;
  final bool showTitle;

  const _ImageAreaWidget({
    required this.title,
    required this.listImages,
    required this.childWidth,
    required this.aspectRatio,
    required this.onTap,
    this.showTitle = false,
  });

  @override
  State<_ImageAreaWidget> createState() => __ImageAreaWidgetState();
}

class __ImageAreaWidgetState extends State<_ImageAreaWidget> {
  List<CampaignVisual> listVisualization = [];

  @override
  void initState() {
    super.initState();
    listVisualization = widget.listImages.toList();
  }

  @override
  void didUpdateWidget(covariant _ImageAreaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listImages != widget.listImages) {
      setState(() {
        listVisualization = List.from(widget.listImages.toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: TextStyle(fontFamily: FontFamily.bungee)),
        GenericFilterWidget<CampaignVisual>(
          listValues: widget.listImages,
          listOrderers: [
            GenericFilterOrderer<CampaignVisual>(
              label: "Por nome",
              iconAscending: Icons.sort_by_alpha,
              iconDescending: Icons.sort_by_alpha,
              orderFunction: (a, b) => a.name.compareTo(b.name),
            ),
          ],
          textExtractor: (p0) => p0.name,
          enableSearch: true,
          onFiltered: (listFiltered) {
            setState(() {
              listVisualization = listFiltered.map((e) => e).toList();
            });
          },
        ),
        SizedBox(height: 16),
        Flexible(
          child: GridView.builder(
            padding: EdgeInsets.only(bottom: 64, right: 16),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: widget.childWidth,
              childAspectRatio: widget.aspectRatio,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: listVisualization.length,
            itemBuilder: (context, index) {
              final visualObject = listVisualization[index];
              return SizedBox(
                height: (!widget.showTitle) ? null : 85,
                width: widget.childWidth,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    InkWell(
                      onTap: () => widget.onTap(visualObject),
                      child: Tooltip(
                        message: visualObject.name,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: visualObject.isEnable
                                  ? AppColors.red
                                  : Colors.transparent,
                            ),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: visualObject.url,
                            placeholder: (context, url) =>
                                Icon(Icons.landscape),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    IconViewImageButton(imageUrl: visualObject.url),
                    if (widget.showTitle)
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withAlpha(175),
                                    Colors.transparent,
                                  ],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.dstIn,
                              child: Container(
                                height: 32,
                                width: double.infinity,
                                color: Colors.black,
                                child: Text(" "),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              visualObject.name,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AudioAreaWidget extends StatefulWidget {
  final String title;
  final AudioProviderType type;
  final List<CampaignVisual> listAudios;
  const _AudioAreaWidget({
    required this.title,
    required this.type,
    required this.listAudios,
  });

  @override
  State<_AudioAreaWidget> createState() => __AudioAreaWidgetState();
}

class __AudioAreaWidgetState extends State<_AudioAreaWidget> {
  List<CampaignVisual> listAudiosVisualization = [];
  double tempVolume = 1;

  @override
  void initState() {
    super.initState();
    listAudiosVisualization = widget.listAudios.toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CampaignProvider campaignVM = Provider.of<CampaignProvider>(
        context,
        listen: false,
      );

      tempVolume = (widget.type == AudioProviderType.music)
          ? campaignVM.campaign!.audioCampaign.musicVolume ?? 1
          : (widget.type == AudioProviderType.ambience)
          ? campaignVM.campaign!.audioCampaign.ambienceVolume ?? 1
          : campaignVM.campaign!.audioCampaign.sfxVolume ?? 1;
    });
  }

  @override
  void didUpdateWidget(covariant _AudioAreaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listAudios != widget.listAudios) {
      setState(() {
        listAudiosVisualization = List.from(widget.listAudios.toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    CampaignProvider campaignVM = Provider.of<CampaignProvider>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: TextStyle(fontFamily: FontFamily.bungee)),
        GenericFilterWidget<CampaignVisual>(
          listValues: widget.listAudios,
          listOrderers: [
            GenericFilterOrderer<CampaignVisual>(
              label: "Por nome",
              iconAscending: Icons.sort_by_alpha,
              iconDescending: Icons.sort_by_alpha,
              orderFunction: (a, b) => a.name.compareTo(b.name),
            ),
          ],
          textExtractor: (p0) => p0.name,
          enableSearch: true,
          onFiltered: (listFiltered) {
            setState(() {
              listAudiosVisualization = listFiltered.map((e) => e).toList();
            });
          },
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Slider(
                value: tempVolume,
                min: 0,
                max: 1,
                onChanged: (value) {
                  setState(() {
                    tempVolume = value;
                  });
                },
                onChangeEnd: (value) {
                  double volume = safeVolume(value);
                  switch (widget.type) {
                    case AudioProviderType.music:
                      campaignVM.campaign!.audioCampaign.musicVolume = volume;
                      break;
                    case AudioProviderType.ambience:
                      campaignVM.campaign!.audioCampaign.ambienceVolume =
                          volume;
                      break;
                    case AudioProviderType.sfx:
                      campaignVM.campaign!.audioCampaign.sfxVolume = volume;
                      break;
                  }
                  AudioProviderFirestore().setAudioCampaign(
                    campaign: campaignVM.campaign!,
                  );
                },
              ),
            ),
            SizedBox(
              width: 25,
              child: Text((tempVolume * 100).toStringAsFixed(0)),
            ),
            IconButton(
              onPressed: () {
                audioProvider.stop(widget.type);
                switch (widget.type) {
                  case AudioProviderType.music:
                    campaignVM.campaign!.audioCampaign.musicUrl = null;
                    campaignVM.campaign!.audioCampaign.musicStarted = null;
                    break;
                  case AudioProviderType.ambience:
                    campaignVM.campaign!.audioCampaign.ambienceUrl = null;
                    campaignVM.campaign!.audioCampaign.ambienceStarted = null;
                    break;
                  case AudioProviderType.sfx:
                    campaignVM.campaign!.audioCampaign.sfxUrl = null;
                    campaignVM.campaign!.audioCampaign.sfxStarted = null;
                    break;
                }

                AudioProviderFirestore().setAudioCampaign(
                  campaign: campaignVM.campaign!,
                );
              },
              tooltip: "Parar",
              icon: Icon(Icons.stop, color: AppColors.red),
            ),
          ],
        ),
        Flexible(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 128),
            itemCount: listAudiosVisualization.length,
            itemBuilder: (context, index) {
              final music = listAudiosVisualization[index];
              return ListTile(
                title: Text(
                  music.name,
                  style: getNeedToHighlight(audioProvider, music.url)
                      ? TextStyle(
                          color: AppColors.red,
                          fontWeight: FontWeight.bold,
                        )
                      : null,
                ),
                leading: widget.type == AudioProviderType.music
                    ? const Icon(Icons.music_note_rounded)
                    : widget.type == AudioProviderType.ambience
                    ? Icon(Icons.landscape)
                    : Icon(Icons.speaker),
                dense: true,
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  setAudio(campaignVM: campaignVM, audio: music);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  bool getNeedToHighlight(AudioProvider audioProvider, String url) {
    if (widget.type == AudioProviderType.music &&
        audioProvider.currentMscUrl != null &&
        (audioProvider.currentMscUrl == url)) {
      return true;
    }

    if (widget.type == AudioProviderType.ambience &&
        audioProvider.currentAmbUrl != null &&
        (audioProvider.currentAmbUrl == url)) {
      return true;
    }

    if (widget.type == AudioProviderType.sfx &&
        audioProvider.currentSfxUrl != null &&
        (audioProvider.currentSfxUrl == url)) {
      return true;
    }
    return false;
  }

  void setAudio({
    required CampaignProvider campaignVM,
    required CampaignVisual audio,
  }) {
    switch (widget.type) {
      case AudioProviderType.music:
        campaignVM.campaign!.audioCampaign.musicUrl = audio.url;
        campaignVM.campaign!.audioCampaign.musicStarted = DateTime.now();
        break;
      case AudioProviderType.ambience:
        campaignVM.campaign!.audioCampaign.ambienceUrl = audio.url;
        campaignVM.campaign!.audioCampaign.ambienceStarted = DateTime.now();
        break;
      case AudioProviderType.sfx:
        campaignVM.campaign!.audioCampaign.sfxUrl = audio.url;
        campaignVM.campaign!.audioCampaign.sfxStarted = DateTime.now();
    }

    AudioProviderFirestore().setAudioCampaign(campaign: campaignVM.campaign!);
  }
}
