import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/version.dart';
import 'package:flutter_rpg_audiodrama/ui/home/components/home_app_bar.dart';
import 'package:flutter_rpg_audiodrama/ui/home/components/home_floating_action_button.dart';
import 'package:flutter_rpg_audiodrama/ui/home/view/home_sheet_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/home/view/home_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/home/widgets/home_drawer.dart';
import 'package:provider/provider.dart';

import '../_core/fonts.dart';
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
      final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
      homeViewModel.onInitialize();

      Provider.of<HomeSheetViewModel>(context, listen: false).onInitialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getHomeAppBar(context),
      floatingActionButton: getHomeFAB(context),
      body: Row(
        children: [
          HomeDrawer(),
          VerticalDivider(thickness: 0.1),
          Flexible(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    return IndexedStack(
      index: HomeSubPages.values.indexOf(viewModel.currentPage),
      children: [
        Stack(
          children: [
            _buildListSheets(),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "dev - $versionDev | rules - $versionBook",
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
            )
          ],
        ),
        Center(child: Text("Ainda não implementado")),
        Center(child: Text("Ainda não implementado")),
      ],
    );
  }

  Widget _buildListSheets() {
    final homeSheetViewModel = Provider.of<HomeSheetViewModel>(context);
    final homeViewModel = Provider.of<HomeViewModel>(context);

    if (homeSheetViewModel.listSheets.isEmpty) {
      return Center(
        child: Text(
          "Nada por aqui ainda, vamos criar?",
          style: TextStyle(
            fontSize: 24,
            fontFamily: FontFamily.sourceSerif4,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          homeSheetViewModel.listSheets.length,
          (index) {
            return HomeListItemWidget(
              sheet: homeSheetViewModel.listSheets[index],
              username: homeViewModel.currentAppUser.username!,
            );
          },
        ),
      ),
    );
  }
}
