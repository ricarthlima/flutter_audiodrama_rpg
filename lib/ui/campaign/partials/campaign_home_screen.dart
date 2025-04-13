import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/providers/audio_provider.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_visual.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/components/image_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/components/movable_expandable_panel.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/generic_header.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/components/tutorial_populate_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_visual_novel_view_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class CampaignHomeScreen extends StatelessWidget {
  const CampaignHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);

    if (campaignVM.isOwner) {
      return _CampaignHomeOwner();
    }

    return _CampaignHomeGuest();
  }
}

class _CampaignHomeGuest extends StatelessWidget {
  final double sizeFactor;
  final bool isPreview;
  const _CampaignHomeGuest({this.sizeFactor = 1.0, this.isPreview = false});

  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);
    return SizedBox(
      width: width(context),
      height: height(context),
      child: Stack(
        children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedSwitcher(
                  duration: Duration(
                      milliseconds: visualVM
                          .data.transitionBackgroundDurationInMilliseconds),
                  child: (visualVM.data.backgroundActive == null)
                      ? Container(
                          key: ValueKey('empty'),
                          color: Colors.black,
                        )
                      : Image.network(
                          visualVM.data.backgroundActive!.url,
                          key: ValueKey(visualVM.data.backgroundActive!.url),
                          fit: BoxFit.cover,
                          width: width(context),
                          height: height(context),
                        ),
                ),
              ),
              if (!isPreview)
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    children: visualVM.data.listObjects
                        .where((e) => e.isEnable)
                        .map(
                          (e) => MovableExpandablePanel(
                            key: ValueKey(e.url),
                            headerTitle: e.name,
                            child: Image.network(e.url),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ] +
            _generateListStack(context, visualVM),
      ),
    );
  }

  List<Widget> _generateListStack(
    BuildContext context,
    CampaignVisualNovelViewModel visualVM,
  ) {
    List<Widget> result = [];

    List<Widget> leftList = [];
    for (int i = 0; i < visualVM.data.listLeftActive.length; i++) {
      CampaignVisual cm = visualVM.data.listLeftActive[i];
      leftList.add(
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: visualVM.data.visualScale *
                  i *
                  visualVM.data.distanceFactor *
                  sizeFactor,
            ),
            child: Image.network(
              cm.url,
              width: visualVM.data.visualScale * sizeFactor,
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
              right: visualVM.data.visualScale *
                  i *
                  visualVM.data.distanceFactor *
                  sizeFactor,
            ),
            child: Transform.flip(
              flipX: true,
              child: Image.network(
                cm.url,
                width: visualVM.data.visualScale * sizeFactor,
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
            style: TextStyle(
              fontSize: 22,
              fontFamily: FontFamily.bungee,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  showTutorialGitHub(context);
                },
                icon: Icon(Icons.podcasts),
                label: Text("Popular com GitHub"),
              ),
            ],
          ),
          Opacity(
            opacity: 0.7,
            child: Text(
                "Utilize uma das opções acima para popular sua mesa de ambientação."),
          ),
        ],
      ),
    );
  }
}

class _CampaignHomeOwner extends StatelessWidget {
  const _CampaignHomeOwner();

  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);

    if (visualVM.isEmpty) {
      return _CampaignOwnerEmpty();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 32, left: 32, right: 96),
      child: SizedBox(
        width: width(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            _ListSettings(),
            Divider(thickness: 0.05),
            SizedBox(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: _ListCharactersVisual(),
                ),
                VerticalDivider(),
                Container(
                  height: 300,
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
                    child: _CampaignHomeGuest(
                      sizeFactor: 300 / height(context),
                      isPreview: true,
                    ),
                  ),
                ),
                VerticalDivider(),
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: _ListCharactersVisual(
                    isRight: true,
                  ),
                ),
              ],
            ),
            Divider(thickness: 0.05),
            _ListBackgrounds(),
            Divider(thickness: 0.05),
            _ListSounds(),
          ],
        ),
      ),
    );
  }
}

class _ListSettings extends StatelessWidget {
  const _ListSettings();

  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(
          "Mesa de Ambientação",
          style: TextStyle(
            fontFamily: FontFamily.bungee,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 16,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  showTutorialGitHub(context);
                },
                icon: Icon(Icons.podcasts),
                label: Text("Popular com GitHub"),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  visualVM.onRemove();
                },
                icon: Icon(Icons.delete_forever),
                label: Text("Limpar tudo"),
              )
            ],
          ),
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
            style: TextStyle(
              fontFamily: FontFamily.bungee,
            ),
          ),
        if (isRight)
          Text(
            "Personagens da Direita",
            style: TextStyle(
              fontFamily: FontFamily.bungee,
            ),
          ),
        CheckboxListTile(
          value: (isRight) ? visualVM.isClearRight : visualVM.isClearLeft,
          contentPadding: EdgeInsets.zero,
          onChanged: (value) {
            if (isRight) {
              visualVM.isClearRight = !visualVM.isClearRight;
            } else {
              visualVM.isClearLeft = !visualVM.isClearLeft;
            }
          },
          title: Text("Limpar ao mudar fundo"),
        ),
        SizedBox(
          height: 250,
          child: MasonryGridView.builder(
            controller: scrollController,
            padding: EdgeInsets.zero,
            gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120, // largura máxima por item
            ),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: visualVM.data.listPortraits.length,
            itemBuilder: (context, index) {
              CampaignVisual cv = visualVM.data.listPortraits[index];
              return _ImageVisualItem(
                visual: cv,
                isRight: isRight,
              );
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

  const _ImageVisualItem({
    required this.visual,
    required this.isRight,
  });

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
            CachedNetworkImage(
              imageUrl: visual.url,
              width: 100,
            ),
            IconViewImageButton(imageUrl: visual.url),
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
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListBackgrounds extends StatelessWidget {
  _ListBackgrounds();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        GenericHeader(
          title: "Planos de fundo",
          dense: true,
        ),
        Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          trackVisibility: true,
          thickness: 4,
          child: Container(
            height: 90,
            padding: EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: visualVM.data.listBackgrounds.length,
              itemBuilder: (context, index) {
                final visualBG = visualVM.data.listBackgrounds[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _BackgroundItem(visualBG: visualBG),
                );
              },
            ),
          ),
        )
      ],
    );
  }
}

class _BackgroundItem extends StatelessWidget {
  final CampaignVisual visualBG;
  const _BackgroundItem({required this.visualBG});

  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);
    return InkWell(
      onTap: () {
        visualVM.toggleBackground(visualBG);
      },
      child: Container(
        height: 90,
        width: 160,
        decoration: BoxDecoration(
          border: visualVM.data.backgroundActive == visualBG
              ? Border.all(width: 4, color: AppColors.red)
              : Border.all(width: 4, color: Colors.transparent),
        ),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: visualBG.url,
              placeholder: (context, url) => Icon(Icons.landscape),
              fit: BoxFit.cover,
              height: 90,
              width: 160,
            ),
            IconViewImageButton(imageUrl: visualBG.url),
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
                visualBG.name,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListSounds extends StatelessWidget {
  const _ListSounds();

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
          child: _AudioAreaWidget(
            title: "Músicas",
            type: AudioProviderType.music,
            listAudios: visualVM.data.listMusics,
          ),
        ),
        Flexible(
          flex: 3,
          fit: FlexFit.tight,
          child: _AudioAreaWidget(
            title: "Ambientações",
            type: AudioProviderType.ambience,
            listAudios: visualVM.data.listAmbiences,
          ),
        ),
        Flexible(
          flex: 3,
          fit: FlexFit.tight,
          child: _AudioAreaWidget(
            title: "Efeitos",
            type: AudioProviderType.sfx,
            listAudios: visualVM.data.listSfxs,
          ),
        ),
        Flexible(
          flex: 3,
          fit: FlexFit.tight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              GenericHeader(
                title: "Objetos, Notas e Itens",
                dense: true,
              ),
              SizedBox(
                height: 300,
                child: MasonryGridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 64,
                  ),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemCount: visualVM.data.listObjects.length,
                  itemBuilder: (context, index) {
                    final visualObject = visualVM.data.listObjects[index];
                    return Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            visualVM.toggleObject(visualObject);
                          },
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
                            ),
                          ),
                        ),
                        IconViewImageButton(imageUrl: visualObject.url),
                      ],
                    );
                  },
                ),
              ),
            ],
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
      CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(
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
  Widget build(BuildContext context) {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 8,
      children: [
        GenericHeader(
          dense: true,
          title: widget.title,
          actions: [
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

                AudioProviderFirestore()
                    .setAudioCampaign(campaign: campaignVM.campaign!);
              },
              tooltip: "Parar",
              icon: Icon(
                Icons.stop,
                color: AppColors.red,
              ),
            )
          ],
          subtitleWidget: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    flex: 8,
                    child: Slider(
                      value: tempVolume,
                      min: 0,
                      max: 1,
                      padding: EdgeInsets.only(right: 32),
                      onChanged: (value) {
                        setState(() {
                          tempVolume = value;
                        });
                      },
                      onChangeEnd: (value) {
                        double volume = safeVolume(value);
                        switch (widget.type) {
                          case AudioProviderType.music:
                            campaignVM.campaign!.audioCampaign.musicVolume =
                                volume;
                            break;
                          case AudioProviderType.ambience:
                            campaignVM.campaign!.audioCampaign.ambienceVolume =
                                volume;
                            break;
                          case AudioProviderType.sfx:
                            campaignVM.campaign!.audioCampaign.sfxVolume =
                                volume;
                            break;
                        }
                        AudioProviderFirestore().setAudioCampaign(
                          campaign: campaignVM.campaign!,
                        );
                      },
                    ),
                  ),
                  Text((tempVolume * 100).toStringAsFixed(0)),
                ],
              )
            ],
          ),
        ),
        SizedBox(
          height: 300,
          child: (widget.type == AudioProviderType.sfx)
              ? MasonryGridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 64,
                  ),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemCount: listAudiosVisualization.length,
                  itemBuilder: (context, index) {
                    final sfx = listAudiosVisualization[index];
                    return InkWell(
                      onTap: () {
                        setAudio(campaignVM: campaignVM, audio: sfx);
                      },
                      child: Tooltip(
                        message: sfx.name,
                        child: SizedBox(
                          height: 72,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1,
                                  color:
                                      getNeedToHighlight(audioProvider, sfx.url)
                                          ? AppColors.red
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color!
                                              .withAlpha(75)),
                            ),
                            padding: EdgeInsets.all(4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 8,
                              children: [
                                Icon(Icons.speaker, size: 18),
                                Expanded(
                                  child: Text(
                                    sfx.name,
                                    overflow: TextOverflow.clip,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
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
                          : Icon(Icons.landscape),
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

  bool getNeedToHighlight(
    AudioProvider audioProvider,
    String url,
  ) {
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

  setAudio({
    required CampaignViewModel campaignVM,
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
