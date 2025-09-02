import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:provider/provider.dart';

import '../../../_core/utils/download_sheet_json.dart';
import '../../../domain/models/list_action.dart';
import '../../_core/widgets/loading_widget.dart';
import '../view/sheet_view_model.dart';
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
        final viewModel = Provider.of<SheetViewModel>(context, listen: false);
        viewModel.refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SheetViewModel sheetViewModel = Provider.of<SheetViewModel>(context);
    return (sheetViewModel.isLoading)
        ? LoadingWidget()
        : (sheetViewModel.isFoundSheet)
        ? _buildBody(context)
        : SheetNotFoundWidget();
  }

  Widget _buildBody(BuildContext context) {
    SheetViewModel sheetVM = Provider.of<SheetViewModel>(context);

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
              children: listItems(sheetVM),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> listItems(SheetViewModel sheetVM) {
    return [
      _SettingItem(
        title: "Opções de Ficha",
        child: ListTile(
          leading: Icon(Icons.download),
          contentPadding: EdgeInsets.zero,
          title: Text("Baixar a ficha como JSON"),
          onTap: () {
            downloadSheetJSON(sheetVM);
          },
        ),
      ),
      _SettingItem(
        title: "Ofícios",
        child: Column(
          children: List.generate(sheetVM.actionRepo.getListWorks().length, (
            index,
          ) {
            ListAction work = sheetVM.actionRepo.getListWorks()[index];
            return SizedBox(
              width: 300,
              child: CheckboxListTile(
                value: sheetVM.sheet!.listActiveWorks.contains(work.name),
                title: Text(
                  work.name[0].toUpperCase() + work.name.substring(1),
                ),
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  sheetVM.toggleActiveWork(work.name);
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
  final Widget child;
  const _SettingItem({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Text(title, style: TextStyle(fontFamily: "Bungee")),
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
