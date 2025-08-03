import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../_core/providers/user_provider.dart';
import '../../_core/web/open_popup/open_popup.dart';
import '../utils/home_tabs.dart';
import 'package:provider/provider.dart';

import '../../_core/dimensions.dart';
import '../../_core/widgets/compactable_button.dart';
import '../view/home_view_model.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return MouseRegion(
      onEnter: (_) => homeViewModel.isDrawerClosed = false,
      onExit: (_) => homeViewModel.isDrawerClosed = true,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 350),
        curve: Curves.ease,
        width: (homeViewModel.isDrawerClosed)
            ? (isVertical(context))
                ? 0
                : 48
            : 275,
        height: height(context),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(245),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              spacing: 8,
              children: [
                CompactableButton(
                  controller: CompactableButtonController(
                    isCompressed: homeViewModel.isDrawerClosed,
                    isSelected: homeViewModel.currentPage == HomeTabs.sheets,
                  ),
                  title: "Personagens",
                  leadingIcon: Icons.list_alt_sharp,
                  onPressed: () {
                    homeViewModel.currentPage = HomeTabs.sheets;
                    changeURL(HomeTabs.sheets.name);
                  },
                ),
                CompactableButton(
                  controller: CompactableButtonController(
                    isCompressed: homeViewModel.isDrawerClosed,
                    isSelected: homeViewModel.currentPage == HomeTabs.campaigns,
                  ),
                  title: "Campanhas",
                  leadingIcon: Icons.local_florist_outlined,
                  onPressed: () {
                    homeViewModel.currentPage = HomeTabs.campaigns;
                    changeURL(HomeTabs.campaigns.name);
                  },
                ),
              ],
            ),
            CompactableButton(
              controller: CompactableButtonController(
                isCompressed: homeViewModel.isDrawerClosed,
                isSelected: homeViewModel.currentPage == HomeTabs.profile,
              ),
              leadingIcon: (userProvider.currentAppUser.imageB64 == null)
                  ? Icons.person_outline
                  : null,
              leading: (userProvider.currentAppUser.imageB64 != null)
                  ? Image.memory(
                      base64Decode(userProvider.currentAppUser.imageB64!),
                      width: 24,
                      height: 24,
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FirebaseAuth.instance.currentUser!.displayName!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    FirebaseAuth.instance.currentUser!.email!,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              onPressed: () {
                homeViewModel.currentPage = HomeTabs.profile;
                changeURL(HomeTabs.profile.name);
              },
            )
          ],
        ),
      ),
    );
  }
}
