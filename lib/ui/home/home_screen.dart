import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/private/auth_user.dart';
import 'package:flutter_rpg_audiodrama/domain/models/sheet_model.dart';
import 'package:flutter_rpg_audiodrama/ui/home/components/home_app_bar.dart';
import 'package:flutter_rpg_audiodrama/ui/home/components/home_floating_action_button.dart';
import 'package:flutter_rpg_audiodrama/ui/home/view/home_view_model.dart';
import 'package:provider/provider.dart';

import '../_core/fonts.dart';
import '../_core/widgets/loading_widget.dart';
import 'widgets/home_list_item_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<HomeViewModel>(context, listen: false);
      viewModel.loadGuestIds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getHomeAppBar(context),
      floatingActionButton: getHomeFAB(context),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    bool isOwnerId =
        FirebaseAuth.instance.currentUser!.uid == SecretAuthIds.ricarthId;

    return SingleChildScrollView(
      child: (isOwnerId && viewModel.mapGuestIds != null)
          ? Column(
              children: <Widget>[
                    SizedBox(height: 16),
                    _buildListSheets(name: "Meus personagens"),
                  ] +
                  viewModel.mapGuestIds!.keys.map(
                    (String name) {
                      return _buildListSheets(
                        name: name,
                        userId: viewModel.mapGuestIds![name],
                      );
                    },
                  ).toList())
          : _buildListSheets(),
    );
  }

  Widget _buildListSheets({
    String? userId,
    String? name,
  }) {
    final viewModel = Provider.of<HomeViewModel>(context);
    // final viewModel = context.read<HomeViewModel>();
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
          stream: viewModel.sheetService.listenSheetsByUser(userId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return LoadingWidget();
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
                          sheet: sheetModel,
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
}
