import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:provider/provider.dart';

import '../../_core/providers/user_provider.dart';
import '../home/widgets/home_list_sheets_widget.dart';

class HomeSheetScreen extends StatefulWidget {
  const HomeSheetScreen({super.key});

  @override
  State<HomeSheetScreen> createState() => _HomeSheetScreenState();
}

class _HomeSheetScreenState extends State<HomeSheetScreen> {
  final PageController pageController = PageController();

  @override
  void initState() {
    pageController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (isVertical(context)) {
      return PageView(
        controller: pageController,
        children: _buildBody(userProvider),
      );
    } else {
      return Row(children: _buildBody(userProvider));
    }
  }

  List<Widget> _buildBody(UserProvider userProvider) {
    return [
      Flexible(
        child: HomeListSheetsWidget(
          title: "Personagens avulsos",
          listSheets: userProvider.listSheetsOutCampaigns,
          username: userProvider.currentAppUser.username!,
        ),
      ),
      Flexible(
        child: HomeListSheetsWidget(
          title: "Personagens em Campanhas",
          listSheets: userProvider.listSheetsInCampaigns,
          username: userProvider.currentAppUser.username!,
          showAdding: false,
        ),
      ),
    ];
  }
}
