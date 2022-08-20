import 'package:get/get.dart';
import 'package:test/models/album.dart';
import 'package:test/models/track.dart';
import 'package:test/services/api.dart';
import 'package:test/services/hive.dart';

class AlbumRepo {
  final hive = Get.find<HiveService>();
  final api = Get.find<ApiService>();

  Future<Album> get(int albumId, {bool online = false}) async {
    if (online) {
      final album = await api.album(albumId);
      await album.persist();
      for (Track track in album.tracks) {
        await track.persist();
      }
      return album;
    }
    final album = hive.albumsBox.get(albumId)!;
    album.tracks = hive.tracksBox.values
        .where((track) => track.albumIds.contains(albumId))
        .toList();

    return album;
  }
}
