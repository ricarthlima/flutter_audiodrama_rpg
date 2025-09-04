// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/campaign.dart';

enum AudioProviderType { music, ambience, sfx }

abstract class _AudioLocalConsts {
  static const String globalLocalVolume = "GLOBAL_LOCAL_VOLUME_KEY";
  static const String musicLocalVolume = "MUSIC_LOCAL_VOLUME_KEY";
  static const String ambienceLocalVolume = "AMBIENCE_LOCAL_VOLUME_KEY";
  static const String sfxLocalVolume = "SFX_LOCAL_VOLUME_KEY";
}

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _mscPlayer = AudioPlayer();
  final AudioPlayer _ambPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  final AudioPlayer _dice01Player = AudioPlayer();
  final AudioPlayer _dice02Player = AudioPlayer();
  final AudioPlayer _dice03Player = AudioPlayer();

  double globalLocalVolume = 1;
  double mscLocalVolume = 1;
  double ambLocalVolume = 1;
  double sfxLocalVolume = 1;

  String? _currentMscUrl;
  String? get currentMscUrl => _currentMscUrl;
  set currentMscUrl(String? value) {
    _currentMscUrl = value;
    notifyListeners();
  }

  String? _currentAmbUrl;
  String? get currentAmbUrl => _currentAmbUrl;
  set currentAmbUrl(String? value) {
    _currentAmbUrl = value;
    notifyListeners();
  }

  String? _currentSfxUrl;
  String? get currentSfxUrl => _currentSfxUrl;
  set currentSfxUrl(String? value) {
    _currentSfxUrl = value;
    notifyListeners();
  }

  String lastTimeStaredSfx = "";
  double _lastMscVolume = 0;
  double _lastAmbVolume = 0;
  double _lastSfxVolume = 0;

  Future<void> onInitialize() async {
    await _mscPlayer.stop();
    await _ambPlayer.stop();
    await _sfxPlayer.stop();
    await _dice01Player.stop();
    await _dice02Player.stop();
    await _dice03Player.stop();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    globalLocalVolume =
        prefs.getDouble(_AudioLocalConsts.globalLocalVolume) ?? 1;

    mscLocalVolume = prefs.getDouble(_AudioLocalConsts.musicLocalVolume) ?? 1;

    ambLocalVolume =
        prefs.getDouble(_AudioLocalConsts.ambienceLocalVolume) ?? 1;

    sfxLocalVolume = prefs.getDouble(_AudioLocalConsts.sfxLocalVolume) ?? 1;

    await _mscPlayer.setLoopMode(LoopMode.one);
    await _ambPlayer.setLoopMode(LoopMode.one);
    await _sfxPlayer.setLoopMode(LoopMode.off);

    await _dice01Player.setLoopMode(LoopMode.off);
    await _dice02Player.setLoopMode(LoopMode.off);
    await _dice03Player.setLoopMode(LoopMode.off);

    int num = Random().nextInt(20);
    await _dice01Player.setAsset("assets/sounds/rolls/roll-$num.ogg");
    num = Random().nextInt(20);
    await _dice02Player.setAsset("assets/sounds/rolls/roll-$num.ogg");
    num = Random().nextInt(20);
    await _dice03Player.setAsset("assets/sounds/rolls/roll-$num.ogg");
  }

  void onDispose() {
    _currentMscUrl = null;
    _currentAmbUrl = null;
    _currentSfxUrl = null;
    _mscPlayer.stop();
    _ambPlayer.stop();
    _sfxPlayer.stop();
    _dice01Player.stop();
    _dice02Player.stop();
    _dice03Player.stop();
  }

  Future<void> changeMusicVolume(double campaignVolume) async {
    final target = safeVolume(
      campaignVolume * globalLocalVolume * mscLocalVolume,
    );
    if (_mscPlayer.volume != target) {
      await _mscPlayer.setVolume(
        campaignVolume * globalLocalVolume * mscLocalVolume,
      );
    }
  }

  Future<void> changeAmbienceVolume(double campaignVolume) async {
    final target = safeVolume(
      campaignVolume * globalLocalVolume * ambLocalVolume,
    );
    if (_ambPlayer.volume != target) {
      await _ambPlayer.setVolume(
        campaignVolume * globalLocalVolume * ambLocalVolume,
      );
    }
  }

  Future<void> changeSfxVolume(double campaignVolume) async {
    final target = safeVolume(
      campaignVolume * globalLocalVolume * sfxLocalVolume,
    );
    if (_sfxPlayer.volume != target) {
      await _sfxPlayer.setVolume(
        campaignVolume * globalLocalVolume * sfxLocalVolume,
      );
    }
  }

  Future<void> setAndPlay({
    required AudioProviderType type,
    required String url,
    required double volume,
    DateTime? timeStarted,
  }) async {
    await _checkUpdateVolume(type: type, volume: volume);

    if (_needToUpdateUrl(type: type, url: url)) {
      switch (type) {
        case AudioProviderType.music:
          await _playWithSync(
            player: _mscPlayer,
            url: url,
            timeStarted: timeStarted,
          );
        case AudioProviderType.ambience:
          await _playWithSync(
            player: _ambPlayer,
            url: url,
            timeStarted: timeStarted,
          );
        case AudioProviderType.sfx:
          await _playSFX(url: url, timeStarted: timeStarted!);
      }
    }

    notifyListeners();
  }

  bool _needToUpdateUrl({
    required AudioProviderType type,
    required String url,
  }) {
    switch (type) {
      case AudioProviderType.music:
        if (url != currentMscUrl) {
          currentMscUrl = url;
          notifyListeners();
          return true;
        }
      case AudioProviderType.ambience:
        if (url != currentAmbUrl) {
          currentAmbUrl = url;
          notifyListeners();
          return true;
        }
      case AudioProviderType.sfx:
        currentSfxUrl = url;
        notifyListeners();
        return true;
    }
    return false;
  }

  Future<void> _checkUpdateVolume({
    required AudioProviderType type,
    required double volume,
  }) async {
    switch (type) {
      case AudioProviderType.music:
        if (_lastMscVolume != volume) {
          _lastMscVolume = volume;
          await changeMusicVolume(volume);
          break;
        }
      case AudioProviderType.ambience:
        if (_lastAmbVolume != volume) {
          _lastAmbVolume = volume;
          await changeAmbienceVolume(volume);
          break;
        }
      case AudioProviderType.sfx:
        if (_lastSfxVolume != volume) {
          _lastSfxVolume = volume;
          await changeSfxVolume(volume);
          break;
        }
    }
  }

  Future<void> _playWithSync({
    required AudioPlayer player,
    required String url,
    required DateTime? timeStarted,
  }) async {
    await player.stop();
    final duration = await player.setUrl(url);

    if (duration != null && timeStarted != null) {
      final elapsed = DateTime.now().difference(timeStarted);
      final offset = Duration(
        milliseconds: elapsed.inMilliseconds % duration.inMilliseconds,
      );
      await player.seek(offset);
    }

    await player.play();

    notifyListeners();
  }

  Future<void> _playSFX({
    required String url,
    required DateTime timeStarted,
  }) async {
    if (lastTimeStaredSfx != timeStarted.toUtc().toString()) {
      lastTimeStaredSfx = timeStarted.toUtc().toString();
      await _sfxPlayer.stop();
      await _sfxPlayer.setUrl(url);
      await _sfxPlayer.play();
    }
  }

  Future<void> changeGlobalVolume(double volume) async {
    volume = safeVolume(volume);

    await _changeGlobalVolume(oldGlobal: globalLocalVolume, newGlobal: volume);
    await saveLocalVolume(globalLV: volume);
  }

  Future<void> changeLocalMusicVolume(double volume) async {
    volume = safeVolume(volume);

    if (volume != mscLocalVolume) {
      await _changeRelativeVolume(
        oldVolume: mscLocalVolume,
        newVolume: volume,
        player: _mscPlayer,
      );
      mscLocalVolume = volume;
      await saveLocalVolume(mscLV: volume);
    }
  }

  Future<void> changeLocalAmbientVolume(double volume) async {
    volume = safeVolume(volume);

    if (volume != ambLocalVolume) {
      _changeRelativeVolume(
        oldVolume: ambLocalVolume,
        newVolume: volume,
        player: _ambPlayer,
      );
      ambLocalVolume = volume;
      await saveLocalVolume(ambLV: volume);
    }
  }

  Future<void> changeLocalSfxVolume(double volume) async {
    volume = safeVolume(volume);

    if (volume != sfxLocalVolume) {
      _changeRelativeVolume(
        oldVolume: sfxLocalVolume,
        newVolume: volume,
        player: _sfxPlayer,
      );
      _changeRelativeVolume(
        oldVolume: sfxLocalVolume,
        newVolume: volume,
        player: _dice01Player,
      );
      _changeRelativeVolume(
        oldVolume: sfxLocalVolume,
        newVolume: volume,
        player: _dice02Player,
      );
      _changeRelativeVolume(
        oldVolume: sfxLocalVolume,
        newVolume: volume,
        player: _dice03Player,
      );
      sfxLocalVolume = volume;
      await saveLocalVolume(sfxLV: volume);
    }
  }

  Future<void> _changeRelativeVolume({
    required double oldVolume,
    required double newVolume,
    required AudioPlayer player,
  }) async {
    await player.setVolume(((player.volume) / oldVolume) * newVolume);
  }

  Future<void> _changeGlobalVolume({
    required double oldGlobal,
    required double newGlobal,
  }) async {
    await _mscPlayer.setVolume((_mscPlayer.volume / oldGlobal) * newGlobal);
    await _ambPlayer.setVolume((_ambPlayer.volume / oldGlobal) * newGlobal);
    await _sfxPlayer.setVolume((_sfxPlayer.volume / oldGlobal) * newGlobal);
  }

  Future<void> saveLocalVolume({
    double? globalLV,
    double? mscLV,
    double? ambLV,
    double? sfxLV,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (globalLV != null) {
      globalLocalVolume = globalLV;
      prefs.setDouble(_AudioLocalConsts.globalLocalVolume, globalLV);
    }

    if (mscLV != null) {
      mscLocalVolume = mscLV;
      prefs.setDouble(_AudioLocalConsts.musicLocalVolume, mscLV);
    }

    if (ambLV != null) {
      ambLocalVolume = ambLV;
      prefs.setDouble(_AudioLocalConsts.ambienceLocalVolume, ambLV);
    }

    if (sfxLV != null) {
      sfxLocalVolume = sfxLV;
      prefs.setDouble(_AudioLocalConsts.sfxLocalVolume, sfxLV);
    }

    notifyListeners();
  }

  Future<void> stop(AudioProviderType type) async {
    switch (type) {
      case AudioProviderType.music:
        _currentMscUrl = null;
        await _mscPlayer.stop();
        break;
      case AudioProviderType.ambience:
        _currentAmbUrl = null;
        await _ambPlayer.stop();
        break;
      case AudioProviderType.sfx:
        _currentSfxUrl = null;
        await _sfxPlayer.stop();
        break;
    }
  }

  Future<void> playDice(int index) async {
    int num = Random().nextInt(20);
    if (index == 0) {
      await _dice01Player.stop();
      await _dice01Player.setAsset("assets/sounds/rolls/roll-$num.ogg");
      await _dice01Player.play();
    } else if (index == 1) {
      await _dice02Player.stop();
      await _dice02Player.setAsset("assets/sounds/rolls/roll-$num.ogg");
      await _dice02Player.play();
    } else if (index == 2) {
      await _dice03Player.stop();
      await _dice03Player.setAsset("assets/sounds/rolls/roll-$num.ogg");
      await _dice03Player.play();
    }
  }
}

// TODO: Esse cara pode rodar para poder ir para CampaignVisualModel
class AudioProviderFirestore {
  Future<void> setAudioCampaign({required Campaign campaign}) async {
    await FirebaseFirestore.instance
        .collection("campaigns")
        .doc(campaign.id)
        .update({"audioCampaign": campaign.audioCampaign.toMap()});
  }
}

class AudioCampaign {
  String? musicUrl;
  double? musicVolume;
  DateTime? musicStarted;

  String? ambienceUrl;
  double? ambienceVolume;
  DateTime? ambienceStarted;

  String? sfxUrl;
  double? sfxVolume;
  DateTime? sfxStarted;

  AudioCampaign({
    this.musicUrl,
    this.musicVolume,
    this.musicStarted,
    this.ambienceUrl,
    this.ambienceVolume,
    this.ambienceStarted,
    this.sfxUrl,
    this.sfxVolume,
    this.sfxStarted,
  });

  AudioCampaign copyWith({
    String? musicUrl,
    double? musicVolume,
    DateTime? musicStarted,
    String? ambienceUrl,
    double? ambienceVolume,
    DateTime? ambienceStarted,
    String? sfxUrl,
    double? sfxVolume,
    DateTime? sfxStarted,
  }) {
    return AudioCampaign(
      musicUrl: musicUrl ?? this.musicUrl,
      musicVolume: musicVolume ?? this.musicVolume,
      musicStarted: musicStarted ?? this.musicStarted,
      ambienceUrl: ambienceUrl ?? this.ambienceUrl,
      ambienceVolume: ambienceVolume ?? this.ambienceVolume,
      ambienceStarted: ambienceStarted ?? this.ambienceStarted,
      sfxUrl: sfxUrl ?? this.sfxUrl,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      sfxStarted: sfxStarted ?? this.sfxStarted,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'musicUrl': musicUrl,
      'musicVolume': musicVolume,
      'musicStarted': musicStarted?.millisecondsSinceEpoch,
      'ambienceUrl': ambienceUrl,
      'ambienceVolume': ambienceVolume,
      'ambienceStarted': ambienceStarted?.millisecondsSinceEpoch,
      'sfxUrl': sfxUrl,
      'sfxVolume': sfxVolume,
      'sfxStarted': sfxStarted?.millisecondsSinceEpoch,
    };
  }

  factory AudioCampaign.fromMap(Map<String, dynamic> map) {
    return AudioCampaign(
      musicUrl: map['musicUrl'] != null ? map['musicUrl'] as String : null,
      musicVolume: map['musicVolume'] != null
          ? map['musicVolume'] as double
          : null,
      musicStarted: map['musicStarted'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['musicStarted'] as int)
          : null,
      ambienceUrl: map['ambienceUrl'] != null
          ? map['ambienceUrl'] as String
          : null,
      ambienceVolume: map['ambienceVolume'] != null
          ? map['ambienceVolume'] as double
          : null,
      ambienceStarted: map['ambienceStarted'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['ambienceStarted'] as int)
          : null,
      sfxUrl: map['sfxUrl'] != null ? map['sfxUrl'] as String : null,
      sfxVolume: map['sfxVolume'] != null ? map['sfxVolume'] as double : null,
      sfxStarted: map['sfxStarted'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['sfxStarted'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AudioCampaign.fromJson(String source) =>
      AudioCampaign.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AudioCampaign(musicUrl: $musicUrl, musicVolume: $musicVolume, musicStarted: $musicStarted, ambienceUrl: $ambienceUrl, ambienceVolume: $ambienceVolume, ambienceStarted: $ambienceStarted, sfxUrl: $sfxUrl, sfxVolume: $sfxVolume, sfxStarted: $sfxStarted)';
  }

  @override
  bool operator ==(covariant AudioCampaign other) {
    if (identical(this, other)) return true;

    return other.musicUrl == musicUrl &&
        other.musicVolume == musicVolume &&
        other.musicStarted == musicStarted &&
        other.ambienceUrl == ambienceUrl &&
        other.ambienceVolume == ambienceVolume &&
        other.ambienceStarted == ambienceStarted &&
        other.sfxUrl == sfxUrl &&
        other.sfxVolume == sfxVolume &&
        other.sfxStarted == sfxStarted;
  }

  @override
  int get hashCode {
    return musicUrl.hashCode ^
        musicVolume.hashCode ^
        musicStarted.hashCode ^
        ambienceUrl.hashCode ^
        ambienceVolume.hashCode ^
        ambienceStarted.hashCode ^
        sfxUrl.hashCode ^
        sfxVolume.hashCode ^
        sfxStarted.hashCode;
  }
}

double safeVolume(double v) {
  if (v <= 0.0) return 0.000001;
  if (v.isNaN || v.isInfinite) return 0.1;
  return v.clamp(0.0, 1.0);
}
