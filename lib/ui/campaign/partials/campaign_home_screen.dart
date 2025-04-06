import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_visual.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/components/image_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/components/movable_expandable_panel.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/generic_header.dart';
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

class _CampaignHomeOwner extends StatelessWidget {
  const _CampaignHomeOwner();

  @override
  Widget build(BuildContext context) {
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
                  //TODO: Modularizar isso
                  showDialog(
                    context: context,
                    builder: (context) {
                      TextEditingController controller =
                          TextEditingController();
                      return AlertDialog(
                        title: Text("Repositório do GitHub"),
                        content: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(label: Text("Url")),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              visualVM.onPopulate(controller.text);
                            },
                            child: Text("Popular"),
                          ),
                        ],
                      );
                    },
                  );
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
          isSmallTitle: true,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 8,
            children: [
              GenericHeader(
                title: "Músicas",
                isSmallTitle: true,
              ),
              SizedBox(
                height: 300,
                child: MasonryGridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent:
                        64, // cada botão terá no máximo essa largura
                  ),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemCount: visualVM.data.listMusics.length,
                  itemBuilder: (context, index) {
                    final music = visualVM.data.listMusics[index];
                    return IconButton(
                      onPressed: () {},
                      tooltip: music.name,
                      icon: const Icon(Icons.music_note_rounded),
                    );
                  },
                ),
              ),
            ],
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
                title: "Ambientações",
                isSmallTitle: true,
              ),
              SizedBox(
                height: 300,
                child: MasonryGridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap:
                      true, // necessário quando dentro de outro scroll (como Column)
                  gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 64,
                  ),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemCount: visualVM.data.listAmbiences.length,
                  itemBuilder: (context, index) {
                    final ambience = visualVM.data.listAmbiences[index];
                    return IconButton(
                      onPressed: () {},
                      tooltip: ambience.name,
                      icon: const Icon(Icons.music_note_rounded),
                    );
                  },
                ),
              ),
            ],
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
                title: "Efeitos",
                isSmallTitle: true,
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
                  itemCount: visualVM.data.listSfxs.length,
                  itemBuilder: (context, index) {
                    final sfx = visualVM.data.listObjects[index];
                    return IconButton(
                      onPressed: () {},
                      tooltip: sfx.name,
                      icon: const Icon(Icons.music_note_rounded),
                    );
                  },
                ),
              ),
            ],
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
                isSmallTitle: true,
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
