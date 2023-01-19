import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:kplayer/kplayer.dart';
import 'package:test/models/track.dart';
import 'package:test/services/downloader.dart';

class PlayerService extends GetxService {
  Future<PlayerService> init() async {
    return this;
  }

  RxList<Track> playlist = RxList<Track>([]);
  Rxn<Track> currentTrack = Rxn<Track>();
  Rx<PlayerStatus> status = PlayerStatus.stopped.obs;
  Rx<Duration> position = Duration.zero.obs;
  Rx<Duration> trackDuration = Duration.zero.obs;

  RxBool loop = true.obs;

  late PlayerController player;
  bool playerInitialized = false;
  late final downloader = Get.find<DownloaderService>();

  bool online = true;

  startPlayer(Track track, List<Track> playlist) async {
    this.playlist(playlist);
    currentTrack(track);
    runPlayer();
  }

  createTrackPlayer(Track track) async {
    String trackId = track.id;
    try {
      playerInitialized = false;
      player.stop();
      player.dispose();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    final localPath = await track.createLocalPath();
    bool isDownloaded = false;
    late PlayerController cPlayer;
    if (await File(localPath).exists()) {
      isDownloaded = true;
      cPlayer = Player.file(localPath, autoPlay: false);
    } else {
      if (!online) {
        nextTrack();
        return;
      }
      final url = await track.getDownloadUrl();
      cPlayer = Player.network(url, autoPlay: false);
    }

    cPlayer.streams.status.listen((event) {
      if (event == PlayerStatus.ended && status.value != event) {
        nextTrack();
      }
      status(event);
      trackDuration(player.duration);
    });

    cPlayer.streams.position.listen((event) {
      position(event);
      trackDuration(player.duration);
    });

    cPlayer.streams.duration.listen((event) {
      trackDuration(event);
    });

    if (currentTrack.value?.id != trackId) {
      cPlayer.stop();
      cPlayer.dispose();
      return;
    }

    player = cPlayer;
    playerInitialized = true;
    player.play();

    if (!isDownloaded) {
      downloader.downloadTracks([
        currentTrack.value!,
      ]);
    }
  }

  nextTrack() {
    if (playerInitialized) player.stop();
    int index = playlist.indexOf(currentTrack.value);

    if (playlist.length > index + 1) {
      currentTrack(playlist[index + 1]);
      runPlayer();
    } else if (loop.value) {
      currentTrack(playlist[0]);
      runPlayer();
    }
  }

  prevTrack() {
    if (playerInitialized) player.stop();
    int index = playlist.indexOf(currentTrack.value);

    if (index - 1 >= 0) {
      currentTrack(playlist[index - 1]);
    } else {
      currentTrack(playlist[0]);
    }
    runPlayer();
  }

  play() {
    if (status.value == PlayerStatus.stopped ||
        status.value == PlayerStatus.ended) {
      runPlayer();
    } else {
      if (playerInitialized) player.play();
    }
  }

  pause() {
    if (playerInitialized) player.pause();
  }

  stop() {
    if (playerInitialized) player.stop();
    currentTrack(playlist.first);
  }

  runPlayer() async {
    try {
      await createTrackPlayer(currentTrack.value!);
    } catch (e) {
      nextTrack();
      rethrow;
    }
  }

  seek(Duration duration) {
    if (!playerInitialized) {
      return;
    }
    player.position = duration;
  }

  bool get isPlaying => status.value == PlayerStatus.playing;
  Duration get duration => playerInitialized ? player.duration : Duration.zero;
}
