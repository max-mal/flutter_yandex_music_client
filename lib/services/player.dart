import 'dart:io';
import 'package:get/get.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:test/models/track.dart';
import 'package:test/services/downloader.dart';
import 'package:just_audio/just_audio.dart';

class PlayerService extends GetxService {
  Future<PlayerService> init() async {
    return this;
  }

  RxList<Track> playlist = RxList<Track>([]);
  Rxn<Track> currentTrack = Rxn<Track>();
  Rx<ProcessingState> status = ProcessingState.idle.obs;
  RxBool playingState = false.obs;
  Rx<Duration> position = Duration.zero.obs;
  Rx<Duration> trackDuration = Duration.zero.obs;

  RxBool loop = true.obs;
  
  late AudioPlayer player;

  bool playerInitialized = false;
  late final downloader = Get.find<DownloaderService>();

  bool online = true;

  startPlayer(Track track, List<Track> playlist) async {
    this.playlist(playlist);
    currentTrack(track);
    runPlayer();
  }

  initializePlayer() async {
    JustAudioMediaKit.ensureInitialized();
    player = AudioPlayer();
    player.durationStream.listen((duration) {
      trackDuration(duration ?? Duration.zero);
    });

    player.positionStream.listen((pos) {
      position(pos);
    });

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && status.value != state.processingState) {
        nextTrack();
      }
      status(state.processingState);
    });

    player.playingStream.listen((event) {
      playingState(event);
    });

    playerInitialized = true;
  }

  createTrackPlayer(Track track) async {
    final localPath = await track.createLocalPath();
    bool isDownloaded = false;
    
    if (!playerInitialized) {
      await initializePlayer();
    }

    if (await File(localPath).exists()) {
      isDownloaded = true;      
      await player.setFilePath(localPath);
    } else {
      if (!online) {
        nextTrack();
        return;
      }
      final url = await track.getDownloadUrl();
      await player.setUrl(url);
    }
       
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
    if (status.value == ProcessingState.idle ||
        status.value == ProcessingState.completed) {
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
    player.seek(duration);
  }

  bool get isPlaying => playerInitialized? player.playing : false;
  Duration get duration => playerInitialized ? (player.duration ?? Duration.zero) : Duration.zero;
}
