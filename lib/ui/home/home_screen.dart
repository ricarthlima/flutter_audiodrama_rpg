import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../_core/providers/user_provider.dart';
import '../../_core/version.dart';
import '../_core/dimensions.dart';
import '../home_campaign/home_campaign_screen.dart';
import 'components/home_app_bar.dart';
import 'utils/home_tabs.dart';
import 'view/home_interact.dart';
import 'view/home_view_model.dart';
import 'widgets/home_drawer.dart';
import 'widgets/home_list_sheets_widget.dart';

class HomeScreen extends StatefulWidget {
  final HomeTabs? page;
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
            index: HomeTabs.values.indexOf(homeViewModel.currentPage),
            children: [
              // Personagens
              HomeListSheetsWidget(
                title: "Meus Personagens",
                subtitle: "(Não inclusos em campanhas)",
                listSheets: userProvider.listSheets
                    .where((e) =>
                        HomeInteract.getWorldName(context: context, sheet: e) ==
                        null)
                    .toList(),
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
