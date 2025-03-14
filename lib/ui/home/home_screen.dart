import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/version.dart';
import 'package:flutter_rpg_audiodrama/ui/home/components/home_app_bar.dart';
import 'package:flutter_rpg_audiodrama/ui/home/view/home_sheet_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/home/view/home_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/home/widgets/home_drawer.dart';
import 'package:flutter_rpg_audiodrama/ui/home/widgets/home_list_sheets_widget.dart';
import 'package:flutter_rpg_audiodrama/ui/home_campaign/home_campaign_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/home_campaign/view/home_campaign_view_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final HomeSubPages page;
  const HomeScreen({super.key, this.page = HomeSubPages.sheets});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      HomeViewModel homeViewModel =
          Provider.of<HomeViewModel>(context, listen: false);
      Provider.of<HomeSheetViewModel>(context, listen: false).onInitialize();
      Provider.of<HomeCampaignViewModel>(context, listen: false).onInitialize();

      homeViewModel.onInitialize();
      homeViewModel.currentPage = widget.page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getHomeAppBar(context),
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
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final homeSheetViewModel = Provider.of<HomeSheetViewModel>(context);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IndexedStack(
            index: HomeSubPages.values.indexOf(homeViewModel.currentPage),
            children: [
              // Personagens
              HomeListSheetsWidget(
                title: "Meus Personagens",
                listSheets: homeSheetViewModel.listSheets,
                username: homeViewModel.currentAppUser.username!,
              ),
              // Campanhas
              HomeCampaignScreen(),
              Center(child: Text("Ainda não implementado")),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
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
    );
  }
}
