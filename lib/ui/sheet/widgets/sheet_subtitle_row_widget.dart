import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/widgets/condition_widget.dart';
import 'package:provider/provider.dart';

import '../../_core/fonts.dart';
import '../../_core/stress_level.dart';
import '../../_core/widgets/named_widget.dart';
import '../../settings/view/settings_provider.dart';
import '../view/sheet_interact.dart';
import '../view/sheet_view_model.dart';

class SheetSubtitleRowWidget extends StatelessWidget {
  final Function onWorksPressed;
  SheetSubtitleRowWidget({super.key, required this.onWorksPressed});

  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: isVertical(context),
      child: Padding(
        padding: EdgeInsets.only(bottom: isVertical(context) ? 16 : 0),
        child: SizedBox(
          width: (isVertical(context)) ? width(context) : null,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                _getListWidget(context).length,
                (index) {
                  return _getListWidget(context)[index];
                },
              ),
            ),
          ),
        ),
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
        hardHeight: 42,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: (sheetVM.sheet!.stressLevel > 0)
                  ? () {
                      sheetVM.changeStressLevel(isAdding: false);
                    }
                  : null,
              padding: EdgeInsets.zero,
              icon: Icon(Icons.remove),
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
            IconButton(
              onPressed: (sheetVM.sheet!.stressLevel < StressLevel.total - 1)
                  ? () {
                      sheetVM.changeStressLevel();
                    }
                  : null,
              padding: EdgeInsets.zero,
              icon: Icon(Icons.add),
            ),
          ],
        ),
      ),
      NamedWidget(
        title: "Esforço",
        tooltip: "Carga de esforço acumulada",
        hardHeight: 42,
        isShowLeftSeparator: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: (sheetVM.sheet!.effortPoints > -1)
                  ? () {
                      sheetVM.changeEffortPoints(
                        isAdding: false,
                      );
                    }
                  : null,
              padding: EdgeInsets.zero,
              icon: Icon(Icons.remove),
            ),
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            ),
            IconButton(
              onPressed: (sheetVM.sheet!.effortPoints < 3)
                  ? () {
                      sheetVM.changeEffortPoints();
                    }
                  : null,
              padding: EdgeInsets.zero,
              icon: Icon(Icons.add),
            ),
          ],
        ),
      ),
      NamedWidget(
        isVisible: !sheetVM.isEditing,
        title: "Estado",
        isShowLeftSeparator: true,
        hardHeight: 42,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (sheetVM.isOwner)
              IconButton(
                onPressed: (sheetVM.sheet!.condition > 0)
                    ? () {
                        sheetVM.removeCondition();
                      }
                    : null,
                icon: Icon(Icons.remove),
              ),
            SizedBox(
              width: 110,
              child: Center(
                child: Condition(condition: sheetVM.sheet!.condition),
              ),
            ),
            if (sheetVM.isOwner)
              IconButton(
                onPressed: (sheetVM.sheet!.condition < 4)
                    ? () {
                        sheetVM.addCondition();
                      }
                    : null,
                padding: EdgeInsets.zero,
                icon: Icon(Icons.add),
              )
          ],
        ),
      ),
      NamedWidget(
        isVisible: !sheetVM.isEditing,
        title: "Descansos",
        hardHeight: 42,
        isShowLeftSeparator: true,
        padding: EdgeInsets.symmetric(horizontal: 16),
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
        hardHeight: 42,
        padding: EdgeInsets.symmetric(horizontal: 16),
        title: "Dados de Corpo",
        isShowLeftSeparator: true,
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
      NamedWidget(
        isVisible: sheetVM.sheet!.listActiveWorks.isNotEmpty,
        padding: EdgeInsets.symmetric(horizontal: 16),
        isShowLeftSeparator: true,
        title: "",
        hardHeight: 42,
        titleWidget: Text(
          "Ofícios",
          style: TextStyle(
            fontFamily: FontFamily.sourceSerif4,
            fontSize: 10,
            color: Colors.amber.withAlpha(150),
          ),
        ),
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
