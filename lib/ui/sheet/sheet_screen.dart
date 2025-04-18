import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_rpg_audiodrama/data/daos/action_dao.dart';
import 'package:flutter_rpg_audiodrama/domain/models/action_template.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/generic_header.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/text_field_dropdown.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/components/sheet_app_bar.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/components/sheet_drawer.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/components/sheet_floating_action_button.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/view/sheet_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/widgets/sheet_actions_columns_widget.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/widgets/sheet_not_found_widget.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/widgets/sheet_subtitle_row_widget.dart';
import 'package:provider/provider.dart';
import '../_core/components/image_dialog.dart';
import '../_core/helpers.dart';
import '../_core/widgets/loading_widget.dart';
import '../_core/widgets/named_widget.dart';
import '../campaign/widgets/group_notifications.dart';

class SheetScreen extends StatefulWidget {
  const SheetScreen({super.key});

  @override
  State<SheetScreen> createState() => _SheetScreenState();
}

class _SheetScreenState extends State<SheetScreen> {
  late final bool Function(KeyEvent) _keyListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<SheetViewModel>(context, listen: false);
      viewModel.refresh();
    });
    _keyListener = _handleKey;
    HardwareKeyboard.instance.addHandler(_keyListener);
  }

  bool _handleKey(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyQ) {
      showSearchDialog().then(
        (value) {
          HardwareKeyboard.instance.addHandler(_keyListener);
          if (value != null) {
            if (!mounted) return;
            ActionTemplate actionTemplate =
                ActionDAO.instance.getAll().firstWhere(
                      (e) => e.name.toLowerCase() == value.toLowerCase(),
                    );
            context.read<SheetViewModel>().rollAction(
                  context: context,
                  action: actionTemplate,
                );
          }
        },
      );
      HardwareKeyboard.instance.removeHandler(_keyListener);
    }
    return false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyListener);
    super.dispose();
  }

  Future<dynamic> showSearchDialog() async {
    if (!context.mounted) return;
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: 600,
            height: 250,
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(
                width: 2,
                color: Theme.of(context).textTheme.titleMedium!.color!,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GenericHeader(title: "Rolagem rápida"),
                TextFieldDropdown(
                  listOptions:
                      ActionDAO.instance.getAll().map((e) => e.name).toList(),
                  autofocus: true,
                  decoration: InputDecoration(
                    label: Text("Busque uma ação"),
                  ),
                  onSubmit: (value) {
                    print(value);
                    Navigator.pop(context, value);
                  },
                ),
                Opacity(
                  opacity: 0.5,
                  child: Text(
                    "Pressione 'Enter' para rolar",
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheetVM = Provider.of<SheetViewModel>(context, listen: false);
    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton:
          (sheetVM.isWindowed) ? null : getSheetFloatingActionButton(context),
      appBar: (sheetVM.isWindowed) ? null : getSheetAppBar(context),
      extendBodyBehindAppBar: true,
      endDrawer: getSheetDrawer(context),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final viewModel = Provider.of<SheetViewModel>(context);

    return (viewModel.isLoading)
        ? LoadingWidget()
        : (viewModel.isAuthorized != null && !viewModel.isAuthorized!)
            ? SheetNotFoundWidget()
            : (viewModel.isFoundSheet)
                ? _generateScreen()
                : SheetNotFoundWidget();
  }

  Widget _generateScreen() {
    final viewModel = Provider.of<SheetViewModel>(context);

    viewModel.nameController.text = viewModel.characterName;

    return Stack(
      children: [
        if (viewModel.imageUrl != null)
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(175),
                  Colors.transparent,
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Image.network(
              viewModel.imageUrl!,
              height: (isVertical(context)) ? 250 : 300,
              width: width(context),
              fit: BoxFit.fitWidth,
            ),
          ),
        Container(
          padding: (viewModel.isWindowed) ? null : EdgeInsets.only(top: 64),
          margin: EdgeInsets.all(16),
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              if (!isVertical(context))
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
                                        InkWell(
                                          onTap: () {
                                            showImageDialog(
                                              context: context,
                                              imageUrl: viewModel.imageUrl!,
                                            );
                                          },
                                          child: Image.network(
                                            viewModel.imageUrl!,
                                            fit: BoxFit.cover,
                                            height: 150,
                                            width: 120,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.delete,
                                              size: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Tooltip(
                                              message: "Remover imagem",
                                              child: InkWell(
                                                onTap: () => viewModel
                                                    .onRemoveImageClicked(),
                                                child: Icon(
                                                  Icons.delete,
                                                  size: 14,
                                                  color: Colors.white,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: viewModel.isOwner
                                          ? [
                                              IconButton(
                                                onPressed: () {
                                                  viewModel
                                                      .onUploadBioImageClicked(
                                                          context);
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
                                            ]
                                          : [],
                                    ),
                                  ),
                          ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            _getNameWidget(viewModel),
                            SheetSubtitleRowWidget(),
                          ],
                        ),
                      ],
                    ),
                    if (width(context) > 750)
                      Column(
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
                                        child: Text(getBaseLevel(0)),
                                      ),
                                      DropdownMenuItem(
                                        value: 1,
                                        child: Text(getBaseLevel(1)),
                                      ),
                                      DropdownMenuItem(
                                        value: 2,
                                        child: Text(getBaseLevel(2)),
                                      ),
                                      DropdownMenuItem(
                                        value: 3,
                                        child: Text(getBaseLevel(3)),
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
                                      viewModel
                                          .getActionsValuesWithWorks()
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
                                      viewModel
                                          .getActionsValuesWithWorks()
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
                  ],
                ),
              if (isVertical(context))
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    _getNameWidget(viewModel),
                    SheetSubtitleRowWidget(),
                  ],
                ),
              Divider(
                thickness: 2,
                height: 48,
              ),
              Flexible(child: SheetActionsColumnsWidget()),
            ],
          ),
        ),
        if (viewModel.isEditing && isVertical(context))
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                viewModel.onUploadBioImageClicked(context);
              },
              icon: Icon(Icons.image),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 80.0),
          child: GroupNotifications(),
        ),
      ],
    );
  }

  NamedWidget _getNameWidget(SheetViewModel viewModel) {
    return NamedWidget(
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
                      fontSize: isVertical(context) ? 18 : 48,
                      fontFamily: FontFamily.sourceSerif4,
                    ),
                  ),
                ),
              )
            : Text(
                viewModel.characterName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isVertical(context) ? 18 : 48,
                  fontFamily: FontFamily.bungee,
                  color: AppColors.red,
                ),
              ),
      ),
    );
  }
}
