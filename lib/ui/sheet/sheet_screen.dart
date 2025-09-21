import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rpg_audiodrama/_core/providers/user_provider.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/constants/roll_type.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/stack_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/components/action_lore_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/components/roll_tip_widget.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/components/roll_widget.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet_module_magic/sheet_module_magic.dart';
import 'package:go_router/go_router.dart';
import '../../router.dart';
import 'helpers/sheet_subpages.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:badges/badges.dart' as badges;

import '../../domain/dto/action_template.dart';
import '../_core/app_colors.dart';
import '../_core/components/image_dialog.dart';
import '../_core/dimensions.dart';
import '../_core/fonts.dart';
import '../_core/helpers.dart';
import '../_core/widgets/generic_header.dart';
import '../_core/widgets/loading_widget.dart';
import '../_core/widgets/named_widget.dart';
import '../_core/widgets/text_field_dropdown.dart';
import '../campaign/widgets/group_notifications.dart';
import '../settings/view/settings_provider.dart';
import '../sheet_notes/sheet_notes.dart';
import '../sheet_shopping/shopping_screen.dart';
import '../sheet_statistics/sheet_statistics_screen.dart';
import 'components/sheet_drawer.dart';
import 'sections/sheet_settings_page.dart';
import 'providers/sheet_interact.dart';
import 'providers/sheet_view_model.dart';
import 'sections/sheet_action_screen.dart';
import 'widgets/sheet_not_found_widget.dart';
import 'widgets/sheet_subtitle_row_widget.dart';

class SheetScreen extends StatefulWidget {
  final String id;
  final String username;
  const SheetScreen({super.key, required this.id, required this.username});

  @override
  State<SheetScreen> createState() => _SheetScreenState();
}

class _SheetScreenState extends State<SheetScreen> {
  late final bool Function(KeyEvent) _keyListener;
  ScrollController rowScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sheetVM = Provider.of<SheetViewModel>(context, listen: false);
      sheetVM.updateCredentials(id: widget.id, username: widget.username);
      sheetVM.refresh();
      _keyListener = _handleKey;
      HardwareKeyboard.instance.addHandler(_keyListener);
    });
  }

  bool _handleKey(KeyEvent event) {
    SheetViewModel sheetVM = context.read<SheetViewModel>();

    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      sheetVM.onStackDialogDismiss();
    } else if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.keyQ &&
        !(sheetVM.showingActionLore != null) &&
        sheetVM.currentPage == SheetSubpages.sheet) {
      showSearchDialog().then((value) {
        HardwareKeyboard.instance.addHandler(_keyListener);
        if (value != null) {
          if (!mounted) return;
          ActionTemplate actionTemplate = context
              .read<SheetViewModel>()
              .actionRepo
              .getAllActions()
              .firstWhere((e) => e.name.toLowerCase() == value.toLowerCase());

          String groupId = context.read<SheetViewModel>().groupByAction(
            actionTemplate.id,
          )!;

          SheetInteract.rollAction(
            context: context,
            action: actionTemplate,
            groupId: groupId,
            rollType: RollType.difficult,
          );
        }
      });
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
            height: 300,
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
                  listOptions: context
                      .read<SheetViewModel>()
                      .actionRepo
                      .getAllActions()
                      .map((e) => e.name)
                      .toList(),
                  autofocus: true,
                  decoration: InputDecoration(label: Text("Busque uma ação")),
                  onSubmit: (value) {
                    Navigator.pop(context, value);
                  },
                ),
                Opacity(
                  opacity: 0.5,
                  child: Text(
                    "Pressione 'Enter' para rolar como Teste de Dificuldade.\nPressione 'Shift+Enter' para rolar como Teste Resistido.",
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
    final sheetVM = Provider.of<SheetViewModel>(context);
    return Scaffold(
      endDrawer: sheetVM.isLoading ? null : getSheetDrawer(context),
      body: _buildBody(sheetVM),
    );
  }

  Widget _buildBody(SheetViewModel sheetVM) {
    return (sheetVM.isLoading)
        ? LoadingWidget()
        : (sheetVM.isAuthorized != null && !sheetVM.isAuthorized!)
        ? SheetNotFoundWidget()
        : (sheetVM.isFoundSheet)
        ? _generateScreen()
        : SheetNotFoundWidget();
  }

  Widget _generateScreen() {
    final sheetVM = Provider.of<SheetViewModel>(context);
    final userProvider = Provider.of<UserProvider>(context);

    sheetVM.nameController.text = sheetVM.sheet!.characterName;

    final themeProvider = Provider.of<SettingsProvider>(context);

    return Stack(
      children: [
        if (sheetVM.sheet!.imageUrl != null)
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withAlpha(175), Colors.transparent],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Image.network(
              sheetVM.sheet!.imageUrl!,
              height: 160,
              width: width(context),
              fit: BoxFit.fitWidth,
            ),
          ),
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      if (!isVertical(context))
                        _buildImageWidget(sheetVM: sheetVM, height: 135),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          _getNameWidget(sheetVM, userProvider),
                          SheetSubtitleRowWidget(
                            onWorksPressed: _rollToShowWorks,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (width(context) > 750) _buildRightInformations(sheetVM),
                ],
              ),
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Flexible(
                      child: IndexedStack(
                        index: sheetVM.currentPage.index,
                        children: [
                          SheetActionsScreen(scrollController: rowScroll),
                          SheetShoppingDialogScreen(),
                          SheetModuleMagic(),
                          SheetNotesScreen(),
                          SheetStatisticsScreen(),
                          SheetSettingsScreen(),
                        ],
                      ),
                    ),
                    _buildSubpageRouter(sheetVM, userProvider, themeProvider),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (sheetVM.isEditing && isVertical(context))
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                SheetInteract.onUploadBioImageClicked(context);
              },
              icon: Icon(Icons.image),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 80.0),
          child: GroupNotifications(),
        ),
        if (sheetVM.currentRollLog.isNotEmpty)
          StackDialog(
            onDismiss: () {
              sheetVM.onStackDialogDismiss();
            },
            child: MultipleRollDialog(listRollLog: sheetVM.currentRollLog),
          ),
        if (sheetVM.showingRollTip != null)
          StackDialog(
            onDismiss: () {
              sheetVM.onStackDialogDismiss();
            },
            child: RollTipStackDialog(
              action: sheetVM.showingRollTip!,
              isEffortUsed: sheetVM.showingRollTip!.isPreparation,
            ),
          ),
        if (sheetVM.showingActionLore != null)
          StackDialog(
            onDismiss: () {
              sheetVM.onStackDialogDismiss();
            },
            child: ActionLoreStackDialog(
              action: sheetVM.showingActionLore!,
              onDismiss: () {
                sheetVM.onStackDialogDismiss();
              },
            ),
          ),
      ],
    );
  }

  void _rollToShowWorks() {
    rowScroll.animateTo(
      rowScroll.position.maxScrollExtent,
      duration: Duration(milliseconds: 750),
      curve: Curves.ease,
    );
  }

  Widget _buildSubpageRouter(
    SheetViewModel sheetVM,
    UserProvider userProvider,
    SettingsProvider themeProvider,
  ) {
    Campaign? campaign = userProvider.getCampaignBySheet(sheetVM.sheet!.id);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 4,
            children: [
              if (sheetVM.sheet!.ownerId ==
                  FirebaseAuth.instance.currentUser!.uid)
                Tooltip(
                  message: "Editar",
                  child: Transform.scale(
                    scale: 0.6,
                    child: Switch(
                      value: sheetVM.isEditing,
                      thumbIcon: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Icon(Icons.save);
                        }
                        return Icon(Icons.edit);
                      }),
                      padding: EdgeInsets.zero,
                      onChanged: (value) {
                        sheetVM.toggleEditMode();
                      },
                    ),
                  ),
                ),
              Opacity(
                opacity: (sheetVM.currentPage == SheetSubpages.sheet) ? 1 : 0.5,
                child: IconButton(
                  tooltip: "Ficha",
                  iconSize: 32,
                  onPressed: () {
                    sheetVM.currentPage = SheetSubpages.sheet;
                  },
                  icon: Icon(Icons.list_alt),
                ),
              ),
              Opacity(
                opacity: (sheetVM.currentPage == SheetSubpages.items) ? 1 : 0.5,
                child: IconButton(
                  tooltip: "Itens",
                  iconSize: 32,
                  onPressed: () {
                    SheetInteract.onItemsButtonClicked(context);
                  },
                  icon: Icon(MdiIcons.treasureChest),
                ),
              ),
              if (sheetVM.showMagicModule(campaign))
                Opacity(
                  opacity: (sheetVM.currentPage == SheetSubpages.magic)
                      ? 1
                      : 0.5,
                  child: IconButton(
                    tooltip: "Magia",
                    iconSize: 32,
                    onPressed: () {
                      SheetInteract.onMagicButtonClicked(context);
                    },
                    icon: Icon(MdiIcons.magicStaff, color: AppColors.module),
                  ),
                ),
              SizedBox(height: 16),
              if (!isVertical(context))
                Opacity(
                  opacity: (sheetVM.currentPage == SheetSubpages.notes)
                      ? 1
                      : 0.5,
                  child: IconButton(
                    tooltip: "Caderneta",
                    iconSize: 32,
                    onPressed: () {
                      SheetInteract.onNotesButtonClicked(context);
                    },
                    icon: Icon(Icons.description),
                  ),
                ),
              if (!isVertical(context))
                Opacity(
                  opacity: (sheetVM.currentPage == SheetSubpages.statistics)
                      ? 1
                      : 0.5,
                  child: IconButton(
                    tooltip: "Estatísticas",
                    iconSize: 32,
                    onPressed: () {
                      SheetInteract.onStatisticsButtonClicked(context);
                    },
                    icon: Icon(Icons.bar_chart),
                  ),
                ),
              Opacity(
                opacity: (sheetVM.currentPage == SheetSubpages.settings)
                    ? 1
                    : 0.5,
                child: IconButton(
                  onPressed: () =>
                      SheetInteract.onSettingsButtonClicked(context),
                  tooltip: "Configurações",
                  iconSize: 32,
                  icon: Icon(Icons.settings),
                ),
              ),
            ],
          ),
          SizedBox(height: 48),
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
                sheetVM.notificationCount = 0;
              },
              tooltip: "Histórico de Rolagens",
              iconSize: 32,
              icon: badges.Badge(
                showBadge:
                    sheetVM.notificationCount >
                    0, // Esconde se não houver notificações
                badgeContent: Text(
                  sheetVM.notificationCount.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                position: badges.BadgePosition.topEnd(
                  top: -10,
                  end: -12,
                ), // Ajusta posição
                child: Icon(Icons.chat),
              ),
            ),
          ),
          if (!sheetVM.isWindowed)
            IconButton(
              tooltip: "Voltar",
              iconSize: 32,
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  AppRouter().goHome(context: context);
                }
              },
              icon: Icon(Icons.home),
            ),
        ],
      ),
    );
  }

  Widget _buildRightInformations(SheetViewModel sheetVM) {
    double trainFontSize = 42;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 8,
      children: [
        AnimatedSwitcher(
          duration: Duration(seconds: 1),
          child: (!sheetVM.isEditing)
              ? Text(
                  getBaseLevel(sheetVM.sheet!.baseLevel),
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: FontFamily.sourceSerif4,
                  ),
                )
              : DropdownButton<int>(
                  value: sheetVM.sheet!.baseLevel,
                  items: [
                    DropdownMenuItem(value: 0, child: Text(getBaseLevel(0))),
                    DropdownMenuItem(value: 1, child: Text(getBaseLevel(1))),
                    DropdownMenuItem(value: 2, child: Text(getBaseLevel(2))),
                    DropdownMenuItem(value: 3, child: Text(getBaseLevel(3))),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        sheetVM.sheet!.baseLevel = value;
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
                    sheetVM
                        .getActionsValuesWithWorks()
                        .where((e) => e.value == 2)
                        .length
                        .toString(),
                    style: TextStyle(
                      fontSize: trainFontSize,
                      fontFamily: FontFamily.bungee,
                    ),
                  ),
                  Text(
                    "/${sheetVM.getAptidaoMaxByLevel()}",
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
                    sheetVM
                        .getActionsValuesWithWorks()
                        .where((e) => e.value == 3)
                        .length
                        .toString(),
                    style: TextStyle(
                      fontSize: trainFontSize,
                      fontFamily: FontFamily.bungee,
                    ),
                  ),
                  Text(
                    "/${sheetVM.getTreinamentoMaxByLevel()}",
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
        if (sheetVM.getPropositoMinusAversao() > 0)
          Text(
            "Faltam ${sheetVM.getPropositoMinusAversao()} aversões",
            style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  AnimatedContainer _buildImageWidget({
    required SheetViewModel sheetVM,
    double height = 135,
  }) {
    double width = height * (135 / 167);

    return AnimatedContainer(
      width: width,
      duration: Duration(milliseconds: 750),
      child: (sheetVM.sheet!.imageUrl != null)
          ? SizedBox(
              height: height,
              width: width,
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {
                      showImageDialog(
                        context: context,
                        imageUrl: sheetVM.sheet!.imageUrl!,
                      );
                    },
                    child: Image.network(
                      sheetVM.sheet!.imageUrl!,
                      fit: BoxFit.cover,
                      height: height,
                      width: width,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Icons.delete, size: 16, color: Colors.black),
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(100),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4,
                        children: [
                          Tooltip(
                            message: "Substituir imagem",
                            child: InkWell(
                              onTap: () =>
                                  SheetInteract.onUploadBioImageClicked(
                                    context,
                                  ),
                              child: Icon(
                                Icons.file_upload_outlined,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Tooltip(
                            message: "Remover imagem",
                            child: InkWell(
                              onTap: () => sheetVM.onRemoveImageClicked(),
                              child: Icon(
                                Icons.delete,
                                size: 14,
                                color: AppColors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              height: height,
              decoration: BoxDecoration(
                color: AppColors.redDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: sheetVM.isOwner
                    ? [
                        IconButton(
                          onPressed: () {
                            SheetInteract.onUploadBioImageClicked(context);
                          },
                          icon: Icon(
                            Icons.file_upload_outlined,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Proporção ideal 4:5\nAté 2MB.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ]
                    : [],
              ),
            ),
    );
  }

  NamedWidget _getNameWidget(
    SheetViewModel sheetVM,
    UserProvider userProvider,
  ) {
    double fontSize = 32;

    return NamedWidget(
      title: "Nome",
      isLeft: true,
      child: AnimatedSwitcher(
        duration: Duration(seconds: 1),
        child: (sheetVM.isEditing)
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width(context) * 0.8,
                  minWidth: width(context) * 0.2,
                ),
                child: IntrinsicWidth(
                  child: TextField(
                    controller: sheetVM.nameController,
                    style: TextStyle(
                      fontSize: isVertical(context) ? 18 : fontSize,
                      fontFamily: FontFamily.sourceSerif4,
                    ),
                  ),
                ),
              )
            : Builder(
                builder: (context) {
                  Campaign? campaign = userProvider.getCampaignBySheet(
                    sheetVM.sheet!.id,
                  );

                  String adding = "";

                  if (campaign != null) {
                    adding = " (${campaign.name})";
                  }

                  return Text(
                    sheetVM.sheet!.characterName + adding,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isVertical(context) ? 18 : fontSize,
                      fontFamily: FontFamily.bungee,
                      color: AppColors.red,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
