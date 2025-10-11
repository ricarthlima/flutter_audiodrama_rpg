import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:provider/provider.dart';

import '../../_core/providers/user_provider.dart';
import '../../_core/version.dart';
import '../../data/services/news_service.dart';
import '../_core/dimensions.dart';
import '../home_campaign/home_campaign_screen.dart';
import '../home_sheet/home_sheet_screen.dart';
import 'components/home_app_bar.dart';
import 'components/news_dialog.dart';
import 'utils/home_tabs.dart';
import 'view/home_view_model.dart';
import 'widgets/home_drawer.dart';

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
      HomeViewModel homeViewModel = Provider.of<HomeViewModel>(
        context,
        listen: false,
      );

      Provider.of<UserProvider>(context, listen: false).onInitialize();

      if (widget.page != null) {
        homeViewModel.currentPage = widget.page!;
      }

      verifyNews();
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
                VerticalDivider(thickness: 0.1, indent: 0, endIndent: 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);

    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IndexedStack(
                  index: HomeTabs.values.indexOf(homeViewModel.currentPage),
                  children: [
                    // Personagens
                    HomeSheetScreen(),

                    // Campanhas
                    HomeCampaignScreen(),

                    // Tutorial
                    Center(child: Text("Ainda não implementado")),

                    // Assistir
                    Center(child: Text("Ainda não implementado")),

                    // Configurações
                    Center(child: Text("Ainda não implementado")),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder(
                    future: versionDev,
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? "",
                        style: TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isVertical(context) && homeViewModel.currentPage.index < 2)
          VerticalDivider(),
        if (!isVertical(context) && homeViewModel.currentPage.index < 2)
          _buildTutorialArea(),
      ],
    );
  }

  void verifyNews() async {
    NewsModel? news = await NewsService.instance.getNews();
    if (mounted && news != null) {
      showNewsDialog(context, news);
    }
  }

  Widget _buildTutorialArea() {
    return Container(
      width: 300,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            "Como jogar?",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: FontFamily.bungee, fontSize: 24),
          ),
          SingleChildScrollView(child: Column()),
        ],
      ),
    );
  }
}
