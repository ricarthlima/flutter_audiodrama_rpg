import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../_core/utils/download_sheet_json.dart';
import '../../../domain/models/list_action.dart';
import '../../_core/widgets/loading_widget.dart';
import '../view/sheet_view_model.dart';
import '../widgets/sheet_not_found_widget.dart';

Future<dynamic> showSheetWorksDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: SheetSettingsPage(),
      );
    },
  );
}

class SheetSettingsPage extends StatefulWidget {
  final bool isPopup;
  const SheetSettingsPage({super.key, this.isPopup = false});

  @override
  State<SheetSettingsPage> createState() => _SheetSettingsPageState();
}

class _SheetSettingsPageState extends State<SheetSettingsPage> {
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

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          SizedBox(height: 8),
          Text(
            "Configurações",
            style: TextStyle(fontFamily: "Bungee", fontSize: 32),
          ),
          Text(
            "Opções de Ficha",
            style: TextStyle(
              fontFamily: "Bungee",
            ),
          ),
          ListTile(
            leading: Icon(Icons.download),
            contentPadding: EdgeInsets.zero,
            title: Text("Baixar a ficha como JSON"),
            onTap: () {
              downloadSheetJSON(sheetVM);
            },
          ),
          Divider(thickness: 0.2),
          Text(
            "Ofícios",
            style: TextStyle(
              fontFamily: "Bungee",
            ),
          ),
          Column(
            children: List.generate(
              sheetVM.actionRepo.getListWorks().length,
              (index) {
                ListAction work = sheetVM.actionRepo.getListWorks()[index];
                return SizedBox(
                  width: 300,
                  child: CheckboxListTile(
                    value: sheetVM.sheet!.listActiveWorks.contains(work.name),
                    title: Text(
                        work.name[0].toUpperCase() + work.name.substring(1)),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      sheetVM.toggleActiveWork(work.name);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
