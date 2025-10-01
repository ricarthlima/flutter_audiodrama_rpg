import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../_core/providers/audio_provider.dart';
import '../../../../domain/models/campaign_visual.dart';
import '../../../_core/app_colors.dart';
import '../../../_core/fonts.dart';
import '../../../_core/widgets/generic_filter_widget.dart';
import '../../view/campaign_view_model.dart';

class AudioAreaWidget extends StatefulWidget {
  final String title;
  final AudioProviderType type;
  final List<CampaignVisual> listAudios;
  const AudioAreaWidget({
    super.key,
    required this.title,
    required this.type,
    required this.listAudios,
  });

  @override
  State<AudioAreaWidget> createState() => _AudioAreaWidgetState();
}

class _AudioAreaWidgetState extends State<AudioAreaWidget> {
  List<CampaignVisual> listAudiosVisualization = [];
  double tempVolume = 1;

  @override
  void initState() {
    super.initState();
    listAudiosVisualization = widget.listAudios.toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CampaignProvider campaignVM = Provider.of<CampaignProvider>(
        context,
        listen: false,
      );

      tempVolume = (widget.type == AudioProviderType.music)
          ? campaignVM.campaign!.audioCampaign.musicVolume ?? 1
          : (widget.type == AudioProviderType.ambience)
          ? campaignVM.campaign!.audioCampaign.ambienceVolume ?? 1
          : campaignVM.campaign!.audioCampaign.sfxVolume ?? 1;
    });
  }

  @override
  void didUpdateWidget(covariant AudioAreaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listAudios != widget.listAudios) {
      setState(() {
        listAudiosVisualization = List.from(widget.listAudios.toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    CampaignProvider campaignVM = Provider.of<CampaignProvider>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title, style: TextStyle(fontFamily: FontFamily.bungee)),
            SizedBox(
              width: 150,
              child: GenericFilterWidget<CampaignVisual>(
                listValues: widget.listAudios,
                listOrderers: [
                  GenericFilterOrderer<CampaignVisual>(
                    label: "Por nome",
                    iconAscending: Icons.sort_by_alpha,
                    iconDescending: Icons.sort_by_alpha,
                    orderFunction: (a, b) => a.name.compareTo(b.name),
                  ),
                ],
                textExtractor: (p0) => p0.name,
                enableSearch: true,
                onFiltered: (listFiltered) {
                  setState(() {
                    listAudiosVisualization = listFiltered
                        .map((e) => e)
                        .toList();
                  });
                },
              ),
            ),
          ],
        ),
        Flexible(
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 128),
                  itemCount: listAudiosVisualization.length,
                  itemBuilder: (context, index) {
                    final music = listAudiosVisualization[index];
                    return ListTile(
                      title: Text(
                        music.name,
                        style: getNeedToHighlight(audioProvider, music.url)
                            ? TextStyle(
                                color: AppColors.red,
                                fontWeight: FontWeight.bold,
                              )
                            : null,
                      ),
                      leading: widget.type == AudioProviderType.music
                          ? const Icon(Icons.music_note_rounded)
                          : widget.type == AudioProviderType.ambience
                          ? Icon(Icons.landscape)
                          : Icon(Icons.speaker),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        setAudio(campaignVM: campaignVM, audio: music);
                      },
                    );
                  },
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      audioProvider.stop(widget.type);
                      switch (widget.type) {
                        case AudioProviderType.music:
                          campaignVM.campaign!.audioCampaign.musicUrl = null;
                          campaignVM.campaign!.audioCampaign.musicStarted =
                              null;
                          break;
                        case AudioProviderType.ambience:
                          campaignVM.campaign!.audioCampaign.ambienceUrl = null;
                          campaignVM.campaign!.audioCampaign.ambienceStarted =
                              null;
                          break;
                        case AudioProviderType.sfx:
                          campaignVM.campaign!.audioCampaign.sfxUrl = null;
                          campaignVM.campaign!.audioCampaign.sfxStarted = null;
                          break;
                      }

                      AudioProviderFirestore().setAudioCampaign(
                        campaign: campaignVM.campaign!,
                      );
                    },
                    child: Tooltip(
                      message: "Parar",
                      child: Icon(Icons.stop, color: AppColors.red),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: Slider(
                        padding: EdgeInsets.only(right: 12),
                        value: tempVolume,
                        min: 0,
                        max: 1,
                        onChanged: (value) {
                          setState(() {
                            tempVolume = value;
                          });
                        },
                        onChangeEnd: (value) {
                          double volume = safeVolume(value);
                          switch (widget.type) {
                            case AudioProviderType.music:
                              campaignVM.campaign!.audioCampaign.musicVolume =
                                  volume;
                              break;
                            case AudioProviderType.ambience:
                              campaignVM
                                      .campaign!
                                      .audioCampaign
                                      .ambienceVolume =
                                  volume;
                              break;
                            case AudioProviderType.sfx:
                              campaignVM.campaign!.audioCampaign.sfxVolume =
                                  volume;
                              break;
                          }
                          AudioProviderFirestore().setAudioCampaign(
                            campaign: campaignVM.campaign!,
                          );
                        },
                      ),
                    ),
                  ),

                  // SizedBox(
                  //   width: 25,
                  //   child: Text((tempVolume * 100).toStringAsFixed(0)),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool getNeedToHighlight(AudioProvider audioProvider, String url) {
    if (widget.type == AudioProviderType.music &&
        audioProvider.currentMscUrl != null &&
        (audioProvider.currentMscUrl == url)) {
      return true;
    }

    if (widget.type == AudioProviderType.ambience &&
        audioProvider.currentAmbUrl != null &&
        (audioProvider.currentAmbUrl == url)) {
      return true;
    }

    if (widget.type == AudioProviderType.sfx &&
        audioProvider.currentSfxUrl != null &&
        (audioProvider.currentSfxUrl == url)) {
      return true;
    }
    return false;
  }

  void setAudio({
    required CampaignProvider campaignVM,
    required CampaignVisual audio,
  }) {
    switch (widget.type) {
      case AudioProviderType.music:
        campaignVM.campaign!.audioCampaign.musicUrl = audio.url;
        campaignVM.campaign!.audioCampaign.musicStarted = DateTime.now();
        break;
      case AudioProviderType.ambience:
        campaignVM.campaign!.audioCampaign.ambienceUrl = audio.url;
        campaignVM.campaign!.audioCampaign.ambienceStarted = DateTime.now();
        break;
      case AudioProviderType.sfx:
        campaignVM.campaign!.audioCampaign.sfxUrl = audio.url;
        campaignVM.campaign!.audioCampaign.sfxStarted = DateTime.now();
    }

    AudioProviderFirestore().setAudioCampaign(campaign: campaignVM.campaign!);
  }
}
