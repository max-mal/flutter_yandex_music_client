import 'package:get/get.dart';
import 'package:test/models/playlist.dart';
import 'package:test/services/api.dart';
import 'package:test/services/hive.dart';

class GeneratedPlaylistsRepo {
  final hive = Get.find<HiveService>();
  final api = Get.find<ApiService>();

  Future<List<Playlist>> get({bool online = false}) async {
    if (online) {
      final playlists = await api.generatedPlaylists();
      await store(playlists);
      return playlists;
    }

    return hive.generatedPlaylists.values.toList();
  }

  store(List<Playlist> playlists) async {
    await hive.generatedPlaylists.clear();
    await hive.generatedPlaylists.addAll(playlists);
    for (Playlist item in playlists) {
      await item.persist();
    }
  }
}
