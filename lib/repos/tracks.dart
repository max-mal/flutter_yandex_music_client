import 'package:get/get.dart';
import 'package:test/models/track.dart';
import 'package:test/repos/user.dart';
import 'package:test/services/api.dart';
import 'package:test/services/hive.dart';

class TracksRepo {
  final api = Get.find<ApiService>();
  final hive = Get.find<HiveService>();

  Future<List<Track>> getFromPlaylist(
    int userId,
    int playlistId, {
    bool online = false,
  }) async {
    if (online) {
      final tracks = await api.playlistTracks(userId, playlistId);
      for (Track track in tracks) {
        await track.persist();
      }

      await hive.playlistTracks.put(
        "$userId/$playlistId",
        tracks.map((e) => e.id.toString()).toList(),
      );

      return tracks;
    }

    final List<String> trackIds =
        hive.playlistTracks.get("$userId/$playlistId", defaultValue: [])!;
    return hive.tracksBox.values
        .where((element) => trackIds.contains(element.id))
        .map((e) => e.withRelations())
        .toList();
  }

  Future<List<Track>> downloaded() async {
    final List<int> trackIds =
        hive.downloadedTracks.keys.map((e) => int.parse(e.toString())).toList();

    return hive.tracksBox.values
        .where((element) => trackIds.contains(element.id))
        .map((e) => e.withRelations())
        .toList();
  }

  Future<List<Track>> liked({bool online = false}) async {
    if (online) {
      final user = await UserRepository().get();
      final likedIds = await api.userLikedTrackIds(user.uid);
      final tracks = await api.tracks(likedIds);

      for (Track track in tracks) {
        await track.persist();
      }

      await hive.playlistTracks.put(
        "liked",
        tracks.map((e) => e.id.toString()).toList(),
      );

      return tracks;
    }

    final List<String> trackIds = hive.playlistTracks.get(
      "liked",
      defaultValue: [],
    )!;

    return hive.tracksBox.values
        .where((element) => trackIds.contains(element.id))
        .map((e) => e.withRelations())
        .toList();
  }

  Future<List<Track>> disliked({bool online = false}) async {
    if (online) {
      final user = await UserRepository().get();
      final likedIds = await api.userDislikedTrackIds(user.uid);
      final tracks = await api.tracks(likedIds);

      for (Track track in tracks) {
        await track.persist();
      }

      await hive.playlistTracks.put(
        "disliked",
        tracks.map((e) => e.id.toString()).toList(),
      );

      return tracks;
    }

    final List<String> trackIds = hive.playlistTracks.get(
      "disliked",
      defaultValue: [],
    )!;

    return hive.tracksBox.values
        .where((element) => trackIds.contains(element.id))
        .map((e) => e.withRelations())
        .toList();
  }

  Future<List<Track>> likeTracks(List<Track> tracks,
      {bool value = true}) async {
    final user = await UserRepository().get();
    await api.userLikeTracks(
      user.uid,
      tracks.map((e) => e.id.toString()).toList(),
      value: value,
    );
    return await liked(online: true);
  }

  Future<List<Track>> dislikeTracks(List<Track> tracks,
      {bool value = true}) async {
    final user = await UserRepository().get();
    await api.userDislikeTracks(
      user.uid,
      tracks.map((e) => e.id.toString()).toList(),
      value: value,
    );
    return await disliked(online: true);
  }
}
