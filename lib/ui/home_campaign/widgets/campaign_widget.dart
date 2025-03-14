import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign.dart';
import 'package:flutter_rpg_audiodrama/router.dart';

import '../../_core/components/show_snackbar.dart';

class CampaignWidget extends StatelessWidget {
  final Campaign campaign;
  const CampaignWidget({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16, bottom: 16),
      width: 400,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).textTheme.bodyMedium!.color!,
          width: 4,
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Stack(
        children: [
          Container(
            alignment: Alignment.topCenter,
            child: (campaign.imageBannerUrl != null)
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    child: Image.network(
                      campaign.imageBannerUrl!,
                      fit: BoxFit.cover,
                      height: 200,
                      width: 400,
                    ),
                  )
                : Container(),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(150),
              ),
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                height: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      campaign.name ?? "",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Jogado em: ${campaign.updatedAt.toString().substring(0, 10)}",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Criado em: ${campaign.createdAt.toString().substring(0, 10)}",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Container(
          //   alignment: Alignment.topLeft,
          //   child: Container(
          //     width: 150,
          //     height: 30,
          //     decoration: BoxDecoration(
          //       color: Colors.black.withAlpha(100),
          //       borderRadius: const BorderRadius.only(
          //         bottomRight: Radius.circular(16),
          //       ),
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.start,
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       children: [
          //         const SizedBox(width: 4),
          //         (urlOwnerImage != null)
          //             ? ClipRRect(
          //                 borderRadius: BorderRadius.circular(8),
          //                 child: Image.network(
          //                   urlOwnerImage!,
          //                   height: 16,
          //                   width: 16,
          //                 ),
          //               )
          //             : const Icon(
          //                 Icons.people,
          //                 size: 16,
          //                 color: Colors.white,
          //               ),
          //         const SizedBox(width: 8),
          //         Text(
          //           widget.campaign.ownerName,
          //           overflow: TextOverflow.ellipsis,
          //           textAlign: TextAlign.left,
          //           style: const TextStyle(
          //             color: Colors.white,
          //             fontSize: 16,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          Container(
            alignment: Alignment.topRight,
            child: Container(
              width: 120,
              height: 30,
              decoration: BoxDecoration(
                color: Theme.of(context).textTheme.titleMedium!.color!,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    campaign.enterCode,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Theme.of(context).cardColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTapDown: (details) {
                      _copyButtonPressed(context);
                    },
                    onTap: () {},
                    child: Icon(
                      Icons.copy,
                      size: 16,
                      color: Theme.of(context).cardColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16, bottom: 13),
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: () {
                AppRouter().goCampaign(
                  context: context,
                  campaignId: campaign.id,
                );
              },
              child: const CircleAvatar(
                child: Icon(Icons.play_arrow_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyButtonPressed(BuildContext context) {
    Clipboard.setData(
      ClipboardData(text: campaign.enterCode),
    ).then((value) {
      if (!context.mounted) return;
      showSnackBar(
        context: context,
        message: "Copiado!",
      );
    });
  }
}
