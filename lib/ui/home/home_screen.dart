import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/helpers.dart';
import 'package:flutter_rpg_audiodrama/_core/private/auth_user.dart';
import 'package:flutter_rpg_audiodrama/domain/models/sheet_model.dart';
import 'package:flutter_rpg_audiodrama/ui/home/components/create_sheet_dialog.dart';
import 'package:flutter_rpg_audiodrama/router.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../_core/fonts.dart';
import '../../data/services/sheet_service.dart';
import '../_core/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, String>? _adminListUserIds;

  @override
  void initState() {
    _loadAdminListUserIds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "AUDIODRAMA RPG",
          style: TextStyle(
            fontFamily: FontFamily.bungee,
          ),
        ),
        elevation: 1,
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
                SheetService().createSheet(value);
              }
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: (FirebaseAuth.instance.currentUser!.uid ==
                    SecretAuthIds.ricarthId &&
                _adminListUserIds != null)
            ? Column(
                children: <Widget>[
                      SizedBox(height: 16),
                      _buildListSheets(name: "Meus personagens"),
                    ] +
                    _adminListUserIds!.keys.map(
                      (String name) {
                        return _buildListSheets(
                          name: name,
                          userId: _adminListUserIds![name],
                        );
                      },
                    ).toList())
            : _buildListSheets(),
      ),
    );
  }

  Widget _buildListSheets({
    String? userId,
    String? name,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        (name != null)
            ? Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Text(
                  name,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Container(),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: SheetService().listenSheetsByUser(userId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Visibility(
                    visible: userId == null,
                    child: Center(
                      child: Text(
                        "Nada por aqui ainda, vamos criar?",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: FontFamily.sourceSerif4,
                        ),
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      snapshot.data!.docs.length,
                      (index) {
                        Map<String, dynamic> map =
                            snapshot.data!.docs[index].data();
                        Sheet sheetModel = Sheet.fromMap(map);
                        return HomeListItemWidget(
                          sheetModel: sheetModel,
                          userId:
                              userId ?? FirebaseAuth.instance.currentUser!.uid,
                        );
                      },
                    ),
                  ),
                );
              case ConnectionState.done:
                return Center(
                  child: Text("Conexão perdida, reinicie a página"),
                );
            }
          },
        ),
        SizedBox(height: 32),
      ],
    );
  }

  void _loadAdminListUserIds() async {
    if (FirebaseAuth.instance.currentUser!.uid == SecretAuthIds.ricarthId) {
      _adminListUserIds = SecretAuthIds.listIds;
      setState(() {});
    }
  }
}

class HomeListItemWidget extends StatelessWidget {
  final String userId;
  final Sheet sheetModel;
  const HomeListItemWidget({
    super.key,
    required this.sheetModel,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.feed,
        size: 48,
      ),
      title: Text(
        sheetModel.characterName,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: (userId == FirebaseAuth.instance.currentUser!.uid)
          ? IconButton(
              onPressed: () {},
              iconSize: 32,
              icon: Icon(
                Icons.delete,
              ),
            )
          : null,
      subtitle: Text(getBaseLevel(sheetModel.baseLevel)),
      onTap: () {
        GoRouter.of(context).go(
          "${AppRouter.sheet}/${sheetModel.id}",
          extra: userId,
        );
      },
    );
  }
}
