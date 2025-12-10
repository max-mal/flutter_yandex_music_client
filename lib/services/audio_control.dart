import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:test/models/track.dart';
import 'package:test/services/audio_handler.dart';
import 'package:test/services/hive.dart';
import 'package:test/services/player.dart';

class AudioControlService extends GetxService {
  late AppAudioHandler handler;
  late PlayerService playerService;

  final hive = Get.find<HiveService>();

  Rxn<Track> currentTrack = Rxn<Track>();
  Rx<Duration> position = Duration.zero.obs;
  Rx<Duration> trackDuration = Duration.zero.obs;
  RxList<Track> tracksList = RxList<Track>([]);
  RxBool isPlaying = false.obs;
  RxBool loop = true.obs;

  bool get usesAudioService => !GetPlatform.isLinux && !GetPlatform.isWindows;

  // TODO Refactor to implementations (PlayerImplementation, AudioServiceImplementation)

  Future<AudioControlService> init() async {
    if (!usesAudioService) {
      playerService = await PlayerService().init();
      playerService.currentTrack.listen((track) {
        currentTrack(track);
      });
      playerService.position.listen((_position) {
        position(_position);
      });
      playerService.trackDuration.listen((_duration) {
        trackDuration(_duration);
      });
      playerService.status.listen((_status) {
        isPlaying(playerService.isPlaying);
      });
      playerService.playingState.listen((playing) {
        isPlaying(playing);
      });
      playerService.loop.listen((_loop) {
        loop(_loop);
      });
      return this;
    }

    handler = await AudioService.init(
      builder: () => AppAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.mycompany.myapp.channel.audio',
        androidNotificationChannelName: 'Music playback',
      ),
    );

    handler.mediaItem.listen((value) {
      if (value == null) {
        currentTrack(null);
        trackDuration(Duration.zero);
        return;
      }
      currentTrack(
        hive.tracksBox.get(value.id),
      );

      trackDuration(value.duration);
    });

    handler.playbackState.listen((PlaybackState value) {
      position(value.position);
      isPlaying(value.playing);
      loop(value.repeatMode == AudioServiceRepeatMode.all);
    });

    return this;
  }

  playTrack(Track track, List<Track> tracks) async {
    tracksList(tracks);
    if (!usesAudioService) {
      await playerService.startPlayer(track, tracks);
      return;
    }

    await handler.updateQueue(
      tracks
          .map((e) => MediaItem(
                id: e.id.toString(),
                title: e.title,
                artist: e.artists.map((e) => e.name).join(','),
                album: e.albums.map((e) => e.title).join(','),
                artUri: Uri.parse(
                  'https://' + e.coverUri.replaceAll('%%', '200x200'),
                ),
              ))
          .toList(),
    );
    final index = tracks.indexOf(track);
    await handler.skipToQueueItem(index);
  }

  play() async {
    if (!usesAudioService) {
      playerService.play();
      return;
    }
    await handler.play();
  }

  pause() async {
    if (!usesAudioService) {
      playerService.pause();
      return;
    }
    await handler.pause();
  }

  stop() async {
    if (!usesAudioService) {
      playerService.stop();
      return;
    }
    await handler.stop();
  }

  nextTrack() async {
    if (!usesAudioService) {
      playerService.nextTrack();
      return;
    }
    await handler.skipToNext();
  }

  prevTrack() async {
    if (!usesAudioService) {
      playerService.prevTrack();
      return;
    }
    await handler.skipToPrevious();
  }

  seek(Duration position) async {
    if (!usesAudioService) {
      playerService.seek(position);
      return;
    }
    await handler.seek(position);
  }

  setOnline(bool value) async {
    if (!usesAudioService) {
      playerService.online = value;
      return;
    }

    await handler.customAction(value ? "setOnline" : "setOffline");
  }

  setLoop(bool value) async {
    loop(!value);
    if (!usesAudioService) {
      playerService.loop(value);
      return;
    }

    await handler.setRepeatMode(
        value ? AudioServiceRepeatMode.all : AudioServiceRepeatMode.none);
  }

  shuffle() async {
    final tracks = List<Track>.from(tracksList);
    tracks.shuffle();
    await playTrack(tracks.first, tracks);
  }
}
