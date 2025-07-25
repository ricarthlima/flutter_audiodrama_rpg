import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../_core/providers/audio_provider.dart';
import '../../../domain/models/campaign_visual.dart';
import '../../_core/app_colors.dart';
import '../../_core/components/image_dialog.dart';
import '../../_core/components/movable_expandable_panel.dart';
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
      CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(
        context,
        listen: false,
      );
      Provider.of<UserProvider>(context, listen: false).playCampaignAudios(
        campaignVM.campaign!,
        context,
      );
    });

    super.initState();
  }

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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Column(
              children: [
                _ListSettings(),
                Divider(thickness: 0.1),
              ],
            ),
            Column(
              children: [
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
                Divider(thickness: 0.1),
              ],
            ),
            // Column(
            //   children: [
            //     _ListBackgrounds(),
            //     Divider(thickness: 0.1),
            //   ],
            // ),
            _RowGroups(),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 16,
      children: [
        Text(
          "Mesa de Ambientação",
          style: TextStyle(
            fontFamily: FontFamily.bungee,
            fontSize: 22,
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

class _RowGroups extends StatelessWidget {
  const _RowGroups();

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
            width: 200,
            showTitle: true,
            onTap: visualVM.toggleBackground,
          ),
        ),
        Flexible(
          flex: 3,
          fit: FlexFit.tight,
          child: _ImageAreaWidget(
            title: "Objetos, Notas e Itens",
            listImages: visualVM.data.listObjects,
            width: 64,
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
  final double width;
  final Function(CampaignVisual object) onTap;
  final bool showTitle;

  const _ImageAreaWidget({
    required this.title,
    required this.listImages,
    required this.width,
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
        Text(
          widget.title,
          style: TextStyle(
            fontFamily: FontFamily.bungee,
          ),
        ),
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
        SizedBox(
          height: 600,
          child: MasonryGridView.builder(
            padding: EdgeInsets.only(bottom: 64),
            shrinkWrap: true,
            gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: widget.width,
            ),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            itemCount: listVisualization.length,
            itemBuilder: (context, index) {
              final visualObject = listVisualization[index];
              return SizedBox(
                height: (!widget.showTitle) ? null : 85,
                child: Stack(
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
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontFamily: FontFamily.bungee,
          ),
        ),
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
        ),
        SizedBox(
          height: 500,
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
