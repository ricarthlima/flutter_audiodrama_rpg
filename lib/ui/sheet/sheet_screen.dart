import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/components/sheet_app_bar.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/components/sheet_drawer.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/components/sheet_floating_action_button.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/view/sheet_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/widgets/sheet_actions_columns_widget.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/widgets/sheet_not_found_widget.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/widgets/sheet_subtitle_row_widget.dart';
import 'package:provider/provider.dart';
import '../_core/helpers.dart';
import '../_core/widgets/loading_widget.dart';
import '../_core/widgets/named_widget.dart';

class SheetScreen extends StatefulWidget {
  const SheetScreen({super.key});

  @override
  State<SheetScreen> createState() => _SheetScreenState();
}

class _SheetScreenState extends State<SheetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<SheetViewModel>(context, listen: false);
      viewModel.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: getSheetFloatingActionButton(context),
      appBar: getSheetAppBar(context),
      endDrawer: getSheetDrawer(context),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final viewModel = Provider.of<SheetViewModel>(context);

    return (viewModel.isLoading)
        ? LoadingWidget()
        : (viewModel.sheet != null)
            ? _generateScreen()
            : SheetNotFoundWidget();
  }

  Widget _generateScreen() {
    final viewModel = Provider.of<SheetViewModel>(context);

    viewModel.nameController.text = viewModel.sheet!.characterName;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(isVertical(context) ? 16 : 32),
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).textTheme.bodyMedium!.color!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 8,
            children: [
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    NamedWidget(
                      title: "Nome",
                      isLeft: true,
                      child: AnimatedSwitcher(
                        duration: Duration(seconds: 1),
                        child: (viewModel.isEditing)
                            ? TextField(
                                controller: viewModel.nameController,
                                style: TextStyle(
                                  fontSize: isVertical(context) ? 18 : 48,
                                  fontFamily: FontFamily.sourceSerif4,
                                ),
                              )
                            : Text(
                                viewModel.sheet!.characterName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isVertical(context) ? 18 : 48,
                                  fontFamily: FontFamily.bungee,
                                  color: AppColors.red,
                                ),
                              ),
                      ),
                    ),
                    SheetSubtitleRowWidget(),
                  ],
                ),
              ),
              Visibility(
                visible: width(context) > 750,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 16,
                  children: [
                    AnimatedSwitcher(
                      duration: Duration(seconds: 1),
                      child: (!viewModel.isEditing)
                          ? Text(
                              getBaseLevel(viewModel.baseLevel),
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: FontFamily.sourceSerif4,
                              ),
                            )
                          : DropdownButton<int>(
                              value: viewModel.baseLevel,
                              items: [
                                DropdownMenuItem(
                                  value: 0,
                                  child: Text("Inexperiente"),
                                ),
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text("Mediocre"),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text("Vivência"),
                                ),
                                DropdownMenuItem(
                                  value: 3,
                                  child: Text("Experiente"),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    viewModel.baseLevel = value;
                                  });
                                }
                              },
                            ),
                    ),
                    Row(
                      spacing: 32,
                      children: [
                        NamedWidget(
                          title: "Aptidões",
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                viewModel.listActionValue
                                    .where(
                                      (e) => e.value == 2,
                                    )
                                    .length
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 64,
                                  fontFamily: FontFamily.bungee,
                                ),
                              ),
                              Text(
                                "/${viewModel.getAptidaoMaxByLevel()}",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: FontFamily.sourceSerif4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        NamedWidget(
                          title: "Treinamentos",
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                viewModel.listActionValue
                                    .where(
                                      (e) => e.value == 3,
                                    )
                                    .length
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 64,
                                  fontFamily: FontFamily.bungee,
                                ),
                              ),
                              Text(
                                "/${viewModel.getTreinamentoMaxByLevel()}",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: FontFamily.sourceSerif4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(),
          Flexible(child: SheetActionsColumnsWidget()),
        ],
      ),
    );
  }
}
