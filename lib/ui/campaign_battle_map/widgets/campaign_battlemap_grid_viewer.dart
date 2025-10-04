import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/named_widget.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/sheet_model.dart';
import '../../_core/fonts.dart';
import '../../_core/widgets/expansible_list.dart';
import '../controllers/battle_map_controller.dart';
import '../helpers/battle_grid_painter.dart';
import '../models/battle_map.dart';
import '../models/token.dart';
import 'token_widget.dart';

class CampaignBattleMapGridViewer extends StatefulWidget {
  final bool isOwner;
  const CampaignBattleMapGridViewer({super.key, this.isOwner = true});

  @override
  State<CampaignBattleMapGridViewer> createState() =>
      _CampaignBattleMapGridViewerState();
}

class _CampaignBattleMapGridViewerState
    extends State<CampaignBattleMapGridViewer> {
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _viewportKey = GlobalKey();
  final GlobalKey _sceneKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final CampaignBattleMapProvider battleMapProvider = context
        .watch<CampaignBattleMapProvider>();

    if (battleMapProvider.battleMap == null) {
      return const Center();
    }

    final BattleMap battleMap = battleMapProvider.battleMap!;
    final Size imageSize = battleMap.imageSize;

    return Stack(
      key: _stackKey,
      fit: StackFit.loose,
      clipBehavior: Clip.hardEdge,
      children: [
        DragTarget<Token>(
          onAcceptWithDetails: (DragTargetDetails<Token> details) {
            final Token token = details.data;

            final Size tokenSize = Size(
              (imageSize.width / battleMap.columns) * token.size.width,
              (imageSize.height / battleMap.rows) * token.size.height,
            );

            final Point<double> scenePoint = _scenePointFromGlobal(
              details.offset,
              battleMapProvider,
            );
            final Point<double> pos = _centered(scenePoint, tokenSize);

            battleMapProvider.moveToken(
              battleMap: battleMap,
              position: pos,
              token: token,
            );
          },
          builder:
              (
                BuildContext context,
                List<Token?> candidateData,
                List<dynamic> rejectedData,
              ) {
                return DragTarget<Sheet>(
                  onAcceptWithDetails: (DragTargetDetails<Sheet> details) {
                    final Sheet sheet = details.data;

                    final Size tokenSize = Size(
                      (imageSize.width / battleMap.columns),
                      (imageSize.height / battleMap.rows),
                    );

                    final Point<double> scenePoint = _scenePointFromGlobal(
                      details.offset,
                      battleMapProvider,
                    );
                    final Point<double> pos = _centered(scenePoint, tokenSize);

                    battleMapProvider.addToken(
                      battleMap: battleMap,
                      position: pos,
                      sheet: sheet,
                    );
                  },
                  builder:
                      (
                        BuildContext context,
                        List<Sheet?> candidateData,
                        List<dynamic> rejectedData,
                      ) {
                        return InteractiveViewer(
                          key: _viewportKey,
                          transformationController: battleMapProvider.gridTrans,
                          constrained: false,
                          minScale: 0.5,
                          maxScale: 6,
                          child: SizedBox(
                            key: _sceneKey,
                            width: imageSize.width,
                            height: imageSize.height,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.network(
                                    battleMap.imageUrl,
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.none,
                                    width: imageSize.width,
                                    height: imageSize.height,
                                  ),
                                ),
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: BattleGridPainter(
                                      cols: battleMap.columns,
                                      rows: battleMap.rows,
                                      color: battleMap.gridColor.withAlpha(
                                        (battleMap.gridOpacity * 255).floor(),
                                      ),
                                      stroke: 1.0,
                                    ),
                                  ),
                                ),
                                for (final Token token in battleMap.listTokens)
                                  Builder(
                                    builder: (BuildContext context) {
                                      final Size sizeInGrid = Size(
                                        (imageSize.width / battleMap.columns) *
                                            token.size.width,
                                        (imageSize.height / battleMap.rows) *
                                            token.size.height,
                                      );
                                      return Positioned(
                                        left: token.position.x,
                                        top: token.position.y,
                                        child: Transform.rotate(
                                          angle: token.rotationDeg * pi / 180.0,
                                          child: TokenWidget(
                                            token: token,
                                            sizeInGrid: sizeInGrid,
                                            // garanta no Draggable interno:
                                            // dragAnchorStrategy: pointerDragAnchorStrategy
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                );
              },
        ),
        if (widget.isOwner)
          Align(
            alignment: Alignment.topCenter,
            child: Container(color: Colors.black.withAlpha(200), height: 40),
          ),
        if (widget.isOwner)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  battleMap.name,
                  style: const TextStyle(
                    fontFamily: FontFamily.bungee,
                    fontSize: 24,
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 32,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.zoom_in),
                        Slider(
                          min: 0.5,
                          max: 6,
                          value: battleMapProvider.zoom,
                          onChanged: (double value) {
                            battleMapProvider.zoom = value;
                            final RenderBox box =
                                _viewportKey.currentContext!.findRenderObject()
                                    as RenderBox;
                            final Size vpSize = box.size;
                            battleMapProvider.setZoom(vpSize);
                          },
                        ),
                      ],
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      double boxWidth = 300;
                      double padding = 8;
                      double width = boxWidth - (padding * 2);

                      return SizedBox(
                        width: boxWidth,
                        child: ExpansibleList(
                          title: "Configurações",
                          startClosed: true,
                          child: Container(
                            color: Colors.black.withAlpha(200),
                            padding: EdgeInsets.all(padding),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  NamedWidget(
                                    title: "Opacidade do grid",
                                    isLeft: true,
                                    child: Slider(
                                      value: battleMap.gridOpacity,
                                      min: 0,
                                      max: 1,
                                      padding: EdgeInsets.zero,
                                      onChanged: (double value) {
                                        battleMap.gridOpacity = value;
                                        battleMapProvider.onUpdate(battleMap);
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: width,

                                    child: CheckboxListTile(
                                      title: Text(
                                        "Limpar personagens da esquerda",
                                      ),
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value: battleMap.clearLeft,
                                      onChanged: (value) {
                                        battleMap.clearLeft =
                                            !battleMap.clearLeft;
                                        battleMapProvider.onUpdate(battleMap);
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: width,
                                    child: CheckboxListTile(
                                      title: Text(
                                        "Limpar personagens da direita",
                                      ),
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value: battleMap.clearRight,
                                      onChanged: (value) {
                                        battleMap.clearRight =
                                            !battleMap.clearRight;
                                        battleMapProvider.onUpdate(battleMap);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Point<double> _scenePointFromGlobal(
    Offset global,
    CampaignBattleMapProvider battleMapProvider,
  ) {
    final RenderBox vp =
        _viewportKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localInViewport = vp.globalToLocal(global);
    final Offset scene = battleMapProvider.gridTrans.toScene(localInViewport);
    return Point<double>(scene.dx, scene.dy);
  }

  Point<double> _centered(Point<double> scenePoint, Size tokenSize) {
    return Point<double>(
      scenePoint.x - tokenSize.width / 2,
      scenePoint.y - tokenSize.height / 2,
    );
  }
}
