import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/version.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/user_provider.dart';
import 'package:flutter_rpg_audiodrama/ui/home/components/home_app_bar.dart';
import 'package:flutter_rpg_audiodrama/ui/home/view/home_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/home/widgets/home_drawer.dart';
import 'package:flutter_rpg_audiodrama/ui/home/widgets/home_list_sheets_widget.dart';
import 'package:flutter_rpg_audiodrama/ui/home_campaign/home_campaign_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final HomeSubPages? page;
  const HomeScreen({super.key, this.page});

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

      Provider.of<UserProvider>(context, listen: false).onInitialize();

      if (widget.page != null) {
        homeViewModel.currentPage = widget.page!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getHomeAppBar(context),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(left: isVertical(context) ? 0 : 64),
            child: _buildBody(context),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              HomeDrawer(),
              if (!isVertical(context))
                VerticalDivider(
                  thickness: 0.1,
                  indent: 0,
                  endIndent: 0,
                ),
            ],
          ),
        ],
      ),

      // Row(
      //   children: [
      //     HomeDrawer(),
      //     VerticalDivider(thickness: 0.1),
      //     Flexible(child: _buildBody(context)),
      //   ],
      // ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final userProvider = Provider.of<UserProvider>(context);

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
                listSheets: userProvider.listSheets,
                username: userProvider.currentAppUser.username!,
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
