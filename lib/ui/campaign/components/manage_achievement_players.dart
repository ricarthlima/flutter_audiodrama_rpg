import 'package:flutter/material.dart';
import '../../../data/services/auth_service.dart';
import '../../../domain/models/app_user.dart';
import '../../../domain/models/campaign_achievement.dart';
import '../../_core/app_colors.dart';
import '../../_core/fonts.dart';
import '../view/campaign_view_model.dart';
import 'package:provider/provider.dart';

Future<void> showManageAchievementPlayersDialog({
  required BuildContext context,
  required CampaignAchievement achievement,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(child: _ManageAchievementPlayers(achievement: achievement));
    },
  );
}

class _ManageAchievementPlayers extends StatefulWidget {
  final CampaignAchievement achievement;
  const _ManageAchievementPlayers({required this.achievement});

  @override
  State<_ManageAchievementPlayers> createState() =>
      _ManageAchievementPlayersState();
}

class _ManageAchievementPlayersState extends State<_ManageAchievementPlayers> {
  List<AppUser> listNotUnlocked = [];
  List<AppUser> listNotUnlockedOriginal = [];

  List<AppUser> listUnlocked = [];
  List<AppUser> listUnlockedOriginal = [];

  bool isLoading = true;

  void loadUserInfos(CampaignViewModel campaignVM) async {
    List<AppUser> listAppUsers = await AuthService().getUserInfoByListIds(
      listIds: campaignVM.campaign!.listIdPlayers,
    );

    for (AppUser appUser in listAppUsers) {
      if (widget.achievement.listUsers.contains(appUser.id)) {
        listUnlocked.add(appUser);
        listUnlockedOriginal.add(appUser);
      } else {
        listNotUnlocked.add(appUser);
        listNotUnlockedOriginal.add(appUser);
      }
    }

    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(
        context,
        listen: false,
      );

      loadUserInfos(campaignVM);
    });
  }

  @override
  Widget build(BuildContext context) {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);

    if (isLoading) return Center(child: CircularProgressIndicator());

    return Container(
      width: 800,
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            spacing: 16,
            children: [
              Text(
                "Gerenciar ${widget.achievement.title}",
                style: TextStyle(fontSize: 24, fontFamily: FontFamily.bungee),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 360,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            "Bloqueados",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: FontFamily.bungee,
                            ),
                          ),
                          Column(
                            children: listNotUnlocked
                                .map(
                                  (e) => ListTile(
                                    title: Text(
                                      e.username!,
                                      style:
                                          (!listNotUnlockedOriginal.contains(e)
                                          ? TextStyle(
                                              color: AppColors.red,
                                              fontWeight: FontWeight.bold,
                                            )
                                          : null),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () => _onMoveUnlocked(e),
                                      icon: Icon(Icons.arrow_forward_ios),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 360,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            "Desbloqueados",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: FontFamily.bungee,
                            ),
                          ),
                          Column(
                            children: listUnlocked
                                .map(
                                  (e) => ListTile(
                                    title: Text(
                                      e.username!,
                                      style: (!listUnlockedOriginal.contains(e)
                                          ? TextStyle(
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.bold,
                                            )
                                          : null),
                                    ),
                                    leading: IconButton(
                                      onPressed: () => _onMoveLocked(e),
                                      icon: Icon(Icons.arrow_back_ios),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 16,
            children: [
              Text("Ao salvar, você notifica as pessoas jogadoras."),
              ElevatedButton(
                onPressed: () {
                  onSaveButton(campaignVM);
                },
                child: Text("Salvar"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onMoveUnlocked(AppUser e) {
    listNotUnlocked.remove(e);
    listUnlocked.add(e);
    setState(() {});
  }

  void _onMoveLocked(AppUser e) {
    listUnlocked.remove(e);
    listNotUnlocked.add(e);
    setState(() {});
  }

  void onSaveButton(CampaignViewModel campaignVM) async {
    await campaignVM.updateAchievement(
      widget.achievement.copyWith(
        listUsers: listUnlocked.map((e) => e.id!).toList(),
      ),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }
}
