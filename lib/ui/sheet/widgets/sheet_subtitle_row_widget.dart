import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/theme_provider.dart';
import 'package:provider/provider.dart';

import '../../_core/dimensions.dart';
import '../../_core/fonts.dart';
import '../../_core/stress_level.dart';
import '../../_core/widgets/named_widget.dart';
import '../view/sheet_view_model.dart';

class SheetSubtitleRowWidget extends StatelessWidget {
  const SheetSubtitleRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SheetViewModel>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 16,
        children: [
          NamedWidget(
            title: "Estresse",
            tooltip: "Nível de estresse atual",
            hardHeight: 32,
            isShowRightSeparator: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                  visible: viewModel.isEditing,
                  child: SizedBox(
                    width: 32,
                    child: (viewModel.stressLevel > 0)
                        ? IconButton(
                            onPressed: () {
                              viewModel.changeStressLevel(isAdding: false);
                            },
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.remove),
                          )
                        : Container(),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    StressLevel().getByStressLevel(viewModel.stressLevel),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FontFamily.bungee,
                    ),
                  ),
                ),
                Visibility(
                  visible: viewModel.isEditing,
                  child: SizedBox(
                    width: 32,
                    child: (viewModel.stressLevel < StressLevel.total - 1)
                        ? IconButton(
                            onPressed: () {
                              viewModel.changeStressLevel();
                            },
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.add),
                          )
                        : Container(),
                  ),
                ),
              ],
            ),
          ),
          NamedWidget(
            title: "Esforço",
            tooltip: "Carga de esforço acumulada",
            hardHeight: 32,
            isShowRightSeparator: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                  visible: viewModel.isEditing,
                  child: SizedBox(
                    width: 32,
                    child: (viewModel.effortPoints > -1)
                        ? IconButton(
                            onPressed: () {
                              viewModel.changeEffortPoints(
                                isAdding: false,
                              );
                            },
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.remove),
                          )
                        : Container(),
                  ),
                ),
                Row(
                  spacing: 8,
                  children: List.generate(
                    3,
                    (index) {
                      return Opacity(
                        opacity: (index <= viewModel.effortPoints) ? 1 : 0.5,
                        child: Image.asset(
                          (themeProvider.themeMode == ThemeMode.dark)
                              ? "assets/images/brain.png"
                              : "assets/images/brain-i.png",
                          width: 16,
                        ),
                      );
                    },
                  ),
                ),
                Visibility(
                  visible: viewModel.isEditing,
                  child: SizedBox(
                    width: 32,
                    child: (viewModel.effortPoints < 3)
                        ? IconButton(
                            onPressed: () {
                              viewModel.changeEffortPoints();
                            },
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.add),
                          )
                        : Container(),
                  ),
                ),
              ],
            ),
          ),
          NamedWidget(
            isVisible: !viewModel.isEditing,
            title: "Mod. Global",
            tooltip: "Modificador global de treinamento",
            hardHeight: 32,
            isShowRightSeparator: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 32,
                  child: (viewModel.modGlobalTrain > -4)
                      ? IconButton(
                          onPressed: () {
                            viewModel.changeModGlobal(isAdding: false);
                          },
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.remove),
                        )
                      : Container(),
                ),
                Tooltip(
                  message: "Clique para manter o modificador",
                  child: SizedBox(
                    width: 42,
                    child: InkWell(
                      onTap: () {
                        viewModel.toggleKeepingGlobalModifier();
                      },
                      child: Text(
                        viewModel.modGlobalTrain.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: FontFamily.bungee,
                          color: (viewModel.isKeepingGlobalModifier)
                              ? AppColors.red
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: (viewModel.modGlobalTrain < 4)
                      ? IconButton(
                          onPressed: () {
                            viewModel.changeModGlobal();
                          },
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.add),
                        )
                      : Container(),
                ),
              ],
            ),
          ),
          NamedWidget(
            isVisible: !isVertical(context) && !viewModel.isEditing,
            title: "Itens",
            tooltip: "Clique para abrir inventário",
            hardHeight: 32,
            isShowRightSeparator: true,
            child: InkWell(
              onTap: () => viewModel.onItemsButtonClicked(context),
              child: Image.asset(
                (themeProvider.themeMode == ThemeMode.dark)
                    ? "assets/images/chest.png"
                    : "assets/images/chest-i.png",
                width: 18,
              ),
            ),
          ),
          if (!viewModel.isEditing)
            NamedWidget(
              title: "Descansos",
              hardHeight: 32,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Tooltip(
                    message: "Descanso curto",
                    child: InkWell(
                      onTap: () {
                        viewModel.changeEffortPoints(isAdding: false);
                      },
                      child: Icon(
                        Icons.fastfood_outlined,
                        size: 18,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: "Descanso longo",
                    child: InkWell(
                      onTap: () {
                        viewModel.changeStressLevel(isAdding: false);
                      },
                      child: Icon(
                        Icons.bed,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
