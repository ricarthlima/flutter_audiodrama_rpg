import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/models/sheet_model.dart';
import 'package:flutter_rpg_audiodrama/f_user/components/create_sheet_dialog.dart';
import 'package:flutter_rpg_audiodrama/router.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../_core/fonts.dart';
import '../../_core/remote_data_manager.dart';
import '../../_core/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "AUDIODRAMA RPG",
          style: TextStyle(
            fontFamily: FontFamilies.bungee,
          ),
        ),
        actions: [
          Icon(Icons.light_mode),
          Switch(
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
          Icon(Icons.dark_mode),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: VerticalDivider(),
          ),
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().then(
                (value) {
                  if (!context.mounted) return;
                  GoRouter.of(context).go(AppRouter.auth);
                },
              );
            },
            icon: Icon(Icons.logout),
          ),
          SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreateSheetDialog(context).then(
            (value) {
              if (value != null) {
                RemoteDataManager().createSheet(value);
              }
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: RemoteDataManager().getSheetsByUser(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
                return ListView(
                  children: List.generate(
                    snapshot.data!.docs.length,
                    (index) {
                      Map<String, dynamic> map =
                          snapshot.data!.docs[index].data();
                      Sheet sheetModel = Sheet.fromMap(map);
                      return HomeListItemWidget(sheetModel: sheetModel);
                    },
                  ),
                );
              case ConnectionState.done:
                return Center(
                  child: Text("Conexão perdida, reinicie a página"),
                );
            }
          }),
    );
  }
}

class HomeListItemWidget extends StatelessWidget {
  final Sheet sheetModel;
  const HomeListItemWidget({super.key, required this.sheetModel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.feed),
      title: Text(sheetModel.characterName),
      trailing: IconButton(
        onPressed: () {},
        icon: Icon(Icons.delete),
      ),
      onTap: () {
        GoRouter.of(context).go("${AppRouter.sheet}/${sheetModel.id}");
      },
    );
  }
}
