import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/providers/user_provider.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:provider/provider.dart';

import '../../../_core/utils/download_sheet_json.dart';
import '../../../data/modules.dart';
import '../../../domain/dto/list_action.dart';
import '../../_core/widgets/loading_widget.dart';
import '../providers/sheet_view_model.dart';
import '../widgets/sheet_not_found_widget.dart';

class SheetSettingsScreen extends StatefulWidget {
  final bool isPopup;
  const SheetSettingsScreen({super.key, this.isPopup = false});

  @override
  State<SheetSettingsScreen> createState() => _SheetSettingsScreenState();
}

class _SheetSettingsScreenState extends State<SheetSettingsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.isPopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final sheetVM = Provider.of<SheetViewModel>(context, listen: false);
        sheetVM.refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SheetViewModel sheetVM = Provider.of<SheetViewModel>(context);
    return (sheetVM.isLoading)
        ? LoadingWidget()
        : (sheetVM.isFoundSheet)
        ? _buildBody(context)
        : SheetNotFoundWidget();
  }

  Widget _buildBody(BuildContext context) {
    SheetViewModel sheetVM = Provider.of<SheetViewModel>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return SizedBox(
      width: (isVertical(context) ? null : width(context) / 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          SizedBox(height: 8),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: listItems(sheetVM, userProvider),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> listItems(SheetViewModel sheetVM, UserProvider userProvider) {
    Campaign? campaign = userProvider.getCampaignBySheet(sheetVM.sheet!.id);

    return [
      _SettingItem(
        title: "Opções de Ficha",
        subtitle: "Configurações gerais sobre a ficha",
        child: ListTile(
          leading: Icon(Icons.download),
          contentPadding: EdgeInsets.zero,
          title: Text("Baixar a ficha como JSON"),
          onTap: () {
            downloadSheetJSON(sheetVM);
          },
        ),
      ),
      if (campaign == null)
        _SettingItem(
          title: "Ofícios",
          subtitle: "Ative e desative ofícios",
          child: Column(
            children: List.generate(sheetVM.actionRepo.getListWorks().length, (
              index,
            ) {
              ListAction work = sheetVM.actionRepo.getListWorks()[index];
              return CheckboxListTile(
                value: sheetVM.sheet!.listActiveWorks.contains(work.name),
                title: Text(
                  work.name[0].toUpperCase() + work.name.substring(1),
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  sheetVM.toggleActiveWork(work.name);
                },
              );
            }),
          ),
        ),
      if (campaign == null)
        _SettingItem(
          title: "Módulos",
          subtitle: "Ative e desative módulos de regras opcionais",
          child: Column(
            children: List.generate(Module.all.length, (index) {
              Module module = Module.all[index];
              return Tooltip(
                message: module.description,
                child: CheckboxListTile(
                  value: sheetVM.sheet!.listActiveModules.contains(module.id),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(module.name),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    sheetVM.toggleActiveModule(module.id);
                  },
                ),
              );
            }),
          ),
        ),
    ];
  }
}

class _SettingItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  const _SettingItem({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontFamily: "Bungee")),
            if (subtitle != null)
              Opacity(
                opacity: 0.5,
                child: Text(
                  subtitle!,
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10),
                ),
              ),
          ],
        ),
        child,
        SizedBox(
          width: (isVertical(context) ? null : width(context) / 2),
          child: Divider(thickness: 0.1),
        ),
        SizedBox(),
      ],
    );
  }
}
