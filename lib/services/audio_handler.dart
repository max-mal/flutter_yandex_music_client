import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:test/models/artist.dart';
import 'package:test/models/track.dart';
import 'package:test/services/player.dart';

class AppAudioHandler extends BaseAudioHandler
    with
        QueueHandler, // mix in default queue callback implementations
        SeekHandler {
  // mix in default seek callback implementations
  final player = Get.put(PlayerService());
  // The most common callbacks:

  PlaybackState _makePlaybackState() {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        player.isPlaying ? MediaControl.pause : MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      // Which controls to show in Android's compact view.
      androidCompactActionIndices: const [0, 1, 3],
      // Whether audio is ready, buffering, ...
      processingState: AudioProcessingState.ready,
      // Whether audio is playing
      playing: player.isPlaying,
      updatePosition: player.position.value,
      // The current buffered psition as of this update
      bufferedPosition:
          player.playerInitialized ? player.player.duration : Duration.zero,
      speed: 1.0,
      // The current queue position
      queueIndex: player.playlist.indexOf(player.currentTrack.value),
      repeatMode: player.loop.value
          ? AudioServiceRepeatMode.all
          : AudioServiceRepeatMode.none,
    );
  }

  _makeMediaItem() {
    if (player.currentTrack.value == null) {
      return null;
    }
    return MediaItem(
      id: player.currentTrack.value!.id.toString(),
      title: player.currentTrack.value!.title,
      artUri: Uri.parse(player.currentTrack.value!.coverUri),
      artist: player.currentTrack.value!.artists.map((e) => e.name).join(','),
      duration:
          player.playerInitialized ? player.player.duration : Duration.zero,
    );
  }

  AppAudioHandler() {
    player.init();
    player.status.listen((_) {
      playbackState.add(_makePlaybackState());
      mediaItem.add(_makeMediaItem());
    });

    player.currentTrack.listen((_) {
      playbackState.add(_makePlaybackState());
      mediaItem.add(_makeMediaItem());
    });

    player.position.listen((_) {
      playbackState.add(_makePlaybackState());
      mediaItem.add(_makeMediaItem());
    });
  }

  @override
  Future<void> play() async {
    player.play();
  }

  @override
  Future<void> pause() async {
    player.pause();
  }

  @override
  Future<void> stop() async {
    player.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    player.player.position = position;
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    player.currentTrack(player.playlist[index]);
    player.runPlayer();
  }

  @override
  Future<void> skipToPrevious() async {
    player.prevTrack();
  }

  @override
  Future<void> skipToNext() async {
    player.nextTrack();
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) {
    player.playlist(newQueue
        .map((e) => Track(
              id: int.parse(e.id),
              title: e.title,
              coverUri: e.artUri.toString(),
              artists: (e.artist ?? "")
                  .split(',')
                  .map((e) => Artist(name: e))
                  .toList(),
            ))
        .toList());
    return super.updateQueue(newQueue);
  }

  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == "setOnline") {
      player.online = true;
    }

    if (name == "setOffline") {
      player.online = false;
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    player.loop(repeatMode == AudioServiceRepeatMode.all);
    playbackState.add(_makePlaybackState());
  }
}
