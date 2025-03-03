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
      // padding: EdgeInsets.all(isVertical(context) ? 16 : 32),
      height: double.infinity,
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     width: 1,
      //     color: Theme.of(context).textTheme.bodyMedium!.color!,
      //   ),
      //   borderRadius: BorderRadius.circular(8),
      // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 16,
                children: [
                  if (!isVertical(context))
                    AnimatedContainer(
                      width: 120,
                      duration: Duration(milliseconds: 750),
                      child: (viewModel.imageUrl != null)
                          ? SizedBox(
                              height: 150,
                              width: 120,
                              child: Stack(
                                children: [
                                  Image.network(
                                    viewModel.imageUrl!,
                                    fit: BoxFit.cover,
                                    height: 150,
                                    width: 120,
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Tooltip(
                                        message: "Remover imagem",
                                        child: InkWell(
                                          onTap: () =>
                                              viewModel.onRemoveImageClicked(),
                                          child: Icon(
                                            Icons.delete,
                                            size: 14,
                                            color: AppColors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: AppColors.redDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      viewModel
                                          .onUploadBioImageClicked(context);
                                    },
                                    icon: Icon(
                                      Icons.file_upload_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Proporção ideal 4:5\nAté 2MB.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
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
                                ? ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: width(context) * 0.8,
                                      minWidth: width(context) * 0.2,
                                    ),
                                    child: IntrinsicWidth(
                                      child: TextField(
                                        controller: viewModel.nameController,
                                        style: TextStyle(
                                          fontSize:
                                              isVertical(context) ? 18 : 48,
                                          fontFamily: FontFamily.sourceSerif4,
                                        ),
                                      ),
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
                ],
              ),
              Visibility(
                visible: width(context) > 750,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                    SizedBox(height: 16),
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
                    if (viewModel.getPropositoMinusAversao() > 0)
                      Text(
                        "Faltam ${viewModel.getPropositoMinusAversao()} aversões",
                        style: TextStyle(
                          color: AppColors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Divider(
            thickness: 2,
            height: 48,
          ),
          Flexible(child: SheetActionsColumnsWidget()),
        ],
      ),
    );
  }
}
