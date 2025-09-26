// import 'package:flutter/material.dart';

// class CampaignPeopleConnected extends StatelessWidget {
//   const CampaignPeopleConnected({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//               stream: ChatService.instance.listenUserPresences(
//                 campaignId: campaignVM.campaign!.id,
//               ),
//               builder: (context, snapshot) {
//                 int count = 1;
//                 List<AppUser> listUsers = [];

//                 if (snapshot.data != null) {
//                   count = snapshot.data!.snapshot.children.length;
//                 }

//                 if (snapshot.data != null) {
//                   for (DataSnapshot data in snapshot.data!.snapshot.children) {
//                     String userId = data.key ?? "";

//                     if (userId == FirebaseAuth.instance.currentUser!.uid) {
//                       listUsers.add(userProvider.currentAppUser);
//                     } else if (userId != "") {
//                       listUsers.add(
//                         campaignVM.listSheetAppUser
//                             .where((e) => e.appUser.id! == userId)
//                             .first
//                             .appUser,
//                       );
//                     }
//                   }
//                 }

//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   spacing: 8,
//                   children: [
//                     Text(
//                       "Pessoas conectadas ($count)",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontFamily: FontFamily.bungee,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 100,
//                       child: SingleChildScrollView(
//                         child: Column(
//                           children: listUsers
//                               .map(
//                                 (e) => ListTile(
//                                   leading: SizedBox(
//                                     width: 18,
//                                     height: 18,
//                                     child: (e.imageB64 != null)
//                                         ? Image.memory(
//                                             base64Decode(e.imageB64!),
//                                           )
//                                         : Icon(Icons.person, size: 18),
//                                   ),
//                                   title: Text(e.username ?? e.id ?? "sem nome"),
//                                   dense: true,
//                                   contentPadding: EdgeInsets.zero,
//                                 ),
//                               )
//                               .toList(),
//                         ),
//                       ),
//                     ),
//                     Divider(thickness: 0.1),
//                   ],
//                 );
//               },
//             );
//   }
// }
