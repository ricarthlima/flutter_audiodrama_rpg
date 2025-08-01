import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../_core/app_colors.dart';
import '../../_core/fonts.dart';
import '../../_core/stress_level.dart';
import '../../_core/widgets/named_widget.dart';
import '../../settings/view/settings_provider.dart';
import '../view/sheet_interact.dart';
import '../view/sheet_view_model.dart';

class SheetSubtitleRowWidget extends StatelessWidget {
  final Function onWorksPressed;
  const SheetSubtitleRowWidget({super.key, required this.onWorksPressed});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: _getListWidget(context),
      ),
    );
  }

  List<Widget> _getListWidget(BuildContext context) {
    final sheetVM = Provider.of<SheetViewModel>(context);
    final themeProvider = Provider.of<SettingsProvider>(context);
    return [
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
              visible: sheetVM.isEditing || sheetVM.isWindowed,
              child: SizedBox(
                width: 32,
                child: (sheetVM.sheet!.stressLevel > 0)
                    ? IconButton(
                        onPressed: () {
                          sheetVM.changeStressLevel(isAdding: false);
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
                StressLevel().getByStressLevel(sheetVM.sheet!.stressLevel),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FontFamily.bungee,
                ),
              ),
            ),
            Visibility(
              visible: sheetVM.isEditing || sheetVM.isWindowed,
              child: SizedBox(
                width: 32,
                child: (sheetVM.sheet!.stressLevel < StressLevel.total - 1)
                    ? IconButton(
                        onPressed: () {
                          sheetVM.changeStressLevel();
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
              visible: sheetVM.isEditing || sheetVM.isWindowed,
              child: SizedBox(
                width: 32,
                child: (sheetVM.sheet!.effortPoints > -1)
                    ? IconButton(
                        onPressed: () {
                          sheetVM.changeEffortPoints(
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
                    opacity: (index <= sheetVM.sheet!.effortPoints) ? 1 : 0.5,
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
              visible: sheetVM.isEditing || sheetVM.isWindowed,
              child: SizedBox(
                width: 32,
                child: (sheetVM.sheet!.effortPoints < 3)
                    ? IconButton(
                        onPressed: () {
                          sheetVM.changeEffortPoints();
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
        isVisible: !sheetVM.isEditing,
        title: "Mod. Global",
        tooltip: "Modificador global de treinamento",
        hardHeight: 32,
        isShowRightSeparator: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (sheetVM.isOwner)
              SizedBox(
                width: 32,
                child: (sheetVM.modGlobalTrain > -4)
                    ? IconButton(
                        onPressed: () {
                          sheetVM.changeModGlobal(isAdding: false);
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
                  onTap: sheetVM.isOwner
                      ? () {
                          sheetVM.toggleKeepingGlobalModifier();
                        }
                      : null,
                  child: Text(
                    sheetVM.modGlobalTrain.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FontFamily.bungee,
                      color: (sheetVM.isKeepingGlobalModifier)
                          ? AppColors.red
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            if (sheetVM.isOwner)
              SizedBox(
                width: 32,
                child: (sheetVM.modGlobalTrain < 4)
                    ? IconButton(
                        onPressed: () {
                          sheetVM.changeModGlobal();
                        },
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.add),
                      )
                    : Container(),
              ),
          ],
        ),
      ),
      if (!sheetVM.isEditing)
        NamedWidget(
          title: "Descansos",
          hardHeight: 32,
          isShowRightSeparator: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Tooltip(
                message: "Descanso curto",
                child: InkWell(
                  onTap: sheetVM.isOwner
                      ? () {
                          sheetVM.changeEffortPoints(isAdding: false);
                        }
                      : null,
                  child: Icon(
                    Icons.fastfood_outlined,
                    size: 18,
                  ),
                ),
              ),
              Tooltip(
                message: "Descanso longo",
                child: InkWell(
                  onTap: sheetVM.isOwner
                      ? () {
                          sheetVM.changeStressLevel(isAdding: false);
                        }
                      : null,
                  child: Icon(
                    Icons.bed,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      NamedWidget(
        isVisible: !sheetVM.isEditing,
        title: "Estado",
        tooltip: "Clique para gerenciar seu estado.",
        hardHeight: 32,
        isShowRightSeparator: true,
        child: Row(
          children: [
            if (sheetVM.isOwner)
              SizedBox(
                width: 32,
                child: (sheetVM.sheet!.condition > 0)
                    ? IconButton(
                        onPressed: () {
                          sheetVM.removeCondition();
                        },
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.remove),
                      )
                    : Container(),
              ),
            SizedBox(
              width: 110,
              child: Center(
                child: Text(
                  getConditionName(sheetVM.sheet!.condition),
                  style: TextStyle(
                    fontFamily: FontFamily.bungee,
                    color:
                        (sheetVM.sheet!.condition > 0) ? AppColors.red : null,
                  ),
                ),
              ),
            ),
            if (sheetVM.isOwner)
              SizedBox(
                width: 32,
                child: (sheetVM.sheet!.condition < 4)
                    ? IconButton(
                        onPressed: () {
                          sheetVM.addCondition();
                        },
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.add),
                      )
                    : Container(),
              ),
          ],
        ),
      ),
      if (!sheetVM.isEditing)
        NamedWidget(
          title: "Dados de Corpo",
          hardHeight: 32,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Tooltip(
                message: "Leve",
                child: InkWell(
                  onTap: () {
                    SheetInteract.onRollBodyDice(
                      context: context,
                      isSerious: false,
                    );
                  },
                  child: Icon(
                    Icons.personal_injury_outlined,
                    size: 18,
                  ),
                ),
              ),
              Tooltip(
                message: "Grave",
                child: InkWell(
                  onTap: () {
                    SheetInteract.onRollBodyDice(
                      context: context,
                      isSerious: true,
                    );
                  },
                  child: Icon(
                    Icons.dangerous_outlined,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      if (sheetVM.sheet!.listActiveWorks.isNotEmpty)
        NamedWidget(
          title: "",
          titleWidget: Text(
            "Ofícios",
            style: TextStyle(
              fontFamily: FontFamily.sourceSerif4,
              fontSize: 10,
              color: Colors.amber.withAlpha(150),
            ),
          ),
          hardHeight: 32,
          isShowLeftSeparator: true,
          child: InkWell(
            onTap: () {
              onWorksPressed.call();
            },
            child: Icon(
              Icons.workspace_premium_sharp,
              color: Colors.amber,
              size: 18,
            ),
          ),
        )
    ];
  }
}

String getConditionName(int condition) {
  switch (condition) {
    case 0:
      return "DESPERTO";
    case 1:
      return "VULNERÁVEL";
    case 2:
      return "INCAPAZ";
    case 3:
      return "MORRENDO";
    case 4:
      return "MORTE";
    default:
      return "DESPERTO";
  }
}
