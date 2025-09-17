import 'package:flutter/material.dart';
// import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
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
  bool isMine = true;

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
    return Column(
      children: [
        Row(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isMine = true;
                });
              },
              style: ButtonStyle(
                backgroundColor: !isMine
                    ? WidgetStatePropertyAll(
                        Theme.of(context).scaffoldBackgroundColor,
                      )
                    : null,
              ),
              child: Text("Privados"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isMine = false;
                });
              },
              style: ButtonStyle(
                backgroundColor: isMine
                    ? WidgetStatePropertyAll(
                        Theme.of(context).scaffoldBackgroundColor,
                      )
                    : null,
              ),
              child: Text("Em campanhas"),
            ),
          ],
        ),
        Flexible(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: (isMine)
                ? HomeListSheetsWidget(
                    key: ValueKey("mine"),
                    title: "Meus personagens",
                    listSheets: userProvider.listSheetsOutCampaigns,
                    username: userProvider.currentAppUser.username!,
                  )
                : HomeListSheetsWidget(
                    key: ValueKey("other"),
                    title: "Personagens de campanhas",
                    listSheets: userProvider.listSheetsInCampaigns,
                    username: userProvider.currentAppUser.username!,
                    showAdding: false,
                  ),
          ),
        ),
      ],
    );
    // if (isVertical(context)) {
    //   return PageView(children: _buildBody(userProvider));
    // } else {
    //   return Row(children: _buildBody(userProvider));
    // }
  }

  // List<Widget> _buildBody(UserProvider userProvider) {
  //   return [
  //     Flexible(
  //       child: HomeListSheetsWidget(
  //         title: "Personagens avulsos",
  //         listSheets: userProvider.listSheetsOutCampaigns,
  //         username: userProvider.currentAppUser.username!,
  //       ),
  //     ),
  //     Flexible(
  //       child: HomeListSheetsWidget(
  //         title: "Personagens em Campanhas",
  //         listSheets: userProvider.listSheetsInCampaigns,
  //         username: userProvider.currentAppUser.username!,
  //         showAdding: false,
  //       ),
  //     ),
  //   ];
  // }
}
