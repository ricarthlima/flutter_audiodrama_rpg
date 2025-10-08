import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../_core/providers/user_provider.dart';
import '../../../_core/utils/download_sheet_json.dart';
import '../../../data/modules.dart';
import '../../../domain/dto/list_action.dart';
import '../../../domain/models/campaign.dart';
import '../../_core/widgets/loading_widget.dart';
import '../providers/sheet_view_model.dart';
import '../widgets/setting_token_item.dart';
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

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: listItems(sheetVM, userProvider),
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
              if (module.id == Module.grid.id) return SizedBox();
              return CheckboxListTile(
                value: sheetVM.sheet!.listActiveModules.contains(module.id),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(module.name),
                subtitle: Text(module.description),
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  sheetVM.toggleActiveModule(module.id);
                },
              );
            }),
          ),
        ),
      if (campaign != null &&
          campaign.campaignSheetSettings.listActiveModuleIds.contains(
            Module.grid.id,
          ))
        _SettingItem(
          title: "Tokens",
          subtitle: "Adicione e escolha entre até 5 tokens.",
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
              children: List.generate(5, (index) {
                return SettingTokenItem(index: index);
              }),
            ),
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
        Divider(thickness: 0.1),
        SizedBox(),
      ],
    );
  }
}
