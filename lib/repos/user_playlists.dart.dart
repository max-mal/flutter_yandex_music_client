import 'package:get/get.dart';
import 'package:test/models/playlist.dart';
import 'package:test/repos/user.dart';
import 'package:test/services/api.dart';
import 'package:test/services/hive.dart';

class UserPlaylistsRepo {
  final hive = Get.find<HiveService>();
  final api = Get.find<ApiService>();

  Future<List<Playlist>> get({bool online = false}) async {
    if (online) {
      final user = await UserRepository().get();
      final playlists = await api.userPlaylists(user.uid);
      await store(playlists);
      return playlists;
    }

    return hive.userPlaylists.values.toList();
  }

  store(List<Playlist> playlists) async {
    await hive.userPlaylists.clear();
    await hive.userPlaylists.addAll(playlists);
    for (Playlist item in playlists) {
      await item.persist();
    }
  }
}
