import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/models/sheet_model.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/models/sheet_template.dart';
import 'package:provider/provider.dart';
import '../../_core/theme_provider.dart';
import 'widgets/list_actions_widget.dart';

class SheetScreen extends StatefulWidget {
  final SheetModel sheet;
  const SheetScreen({super.key, required this.sheet});

  @override
  State<SheetScreen> createState() => _SheetScreenState();
}

class _SheetScreenState extends State<SheetScreen> {
  bool isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    _nameController.text = widget.sheet.characterName;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        actions: [
          Icon(Icons.edit),
          Switch(
            value: isEditing,
            onChanged: (value) {
              setState(() {
                isEditing = !isEditing;
                if (isEditing) {
                  FocusScope.of(context).requestFocus(_nameFocusNode);
                }
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: VerticalDivider(),
          ),
          Icon(Icons.light_mode),
          Switch(
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
          Icon(Icons.dark_mode),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
          tooltip: "Histórico de rolagens",
          child: Icon(Icons.chat),
        ),
      ),
      endDrawer: Drawer(),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 32,
          left: 32,
          right: 32,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 32,
            children: [
              SizedBox(
                height: 150,
                child: Row(
                  spacing: 32,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 200,
                      child: Stack(
                        children: [
                          Image.network(
                            "https://m.media-amazon.com/images/I/71XQaMRKLML._AC_SL1500_.jpg",
                            width: 150,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Visibility(
                              visible: isEditing,
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.edit),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: AnimatedSwitcher(
                        duration: Duration(seconds: 1),
                        child: (isEditing)
                            ? TextField(
                                controller: _nameController,
                                focusNode: _nameFocusNode,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontFamily: Fonts.sourceSerif4,
                                ),
                              )
                            : Text(
                                widget.sheet.characterName,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontFamily: Fonts.bungee,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              SizedBox(
                width: width(context),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  runAlignment: WrapAlignment.center,
                  runSpacing: 32,
                  children: [
                    ListActionsWidget(
                      name: "Ações Básicas",
                      sheet: widget.sheet,
                      isEditing: isEditing,
                      listActions: SheetTemplate.instance.listBasicActions,
                    ),
                    ListActionsWidget(
                      name: "Ações de Força",
                      sheet: widget.sheet,
                      isEditing: isEditing,
                      listActions: SheetTemplate.instance.listStrengthActions,
                    ),
                    ListActionsWidget(
                      name: "Ações de Agilidade",
                      sheet: widget.sheet,
                      isEditing: isEditing,
                      listActions: SheetTemplate.instance.listAgilityActions,
                    ),
                    ListActionsWidget(
                      name: "Ações de Intelecto",
                      sheet: widget.sheet,
                      isEditing: isEditing,
                      listActions: SheetTemplate.instance.listIntellectActions,
                    ),
                    ListActionsWidget(
                      name: "Ações Sociais",
                      sheet: widget.sheet,
                      isEditing: isEditing,
                      listActions: SheetTemplate.instance.listSocialActions,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
