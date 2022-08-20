import 'package:get/get.dart';
import 'package:test/models/album.dart';
import 'package:test/models/artist.dart';
import 'package:test/models/playlist.dart';
import 'package:test/models/search_result.dart';
import 'package:test/models/track.dart';
import 'package:test/services/api.dart';
import 'package:test/services/hive.dart';

class SearchRepo {
  final api = Get.find<ApiService>();
  final hive = Get.find<HiveService>();

  Future<SearchResult> search(String text, {bool online = true}) async {
    if (online) {
      final result = await api.search(text);
      for (Track track in result.tracks) {
        await track.persist();
      }

      for (Album album in result.albums) {
        await album.persist();
      }

      for (Artist artist in result.artists) {
        await artist.persist();
      }

      for (Playlist playlist in result.playlists) {
        await playlist.persist();
      }

      return result;
    }

    final textLowerCase = text.toLowerCase();

    return SearchResult(
      tracks: hive.tracksBox.values
          .where((e) => e.title.toLowerCase().contains(textLowerCase))
          .take(10)
          .toList(),
      albums: hive.albumsBox.values
          .where((e) => e.title.toLowerCase().contains(textLowerCase))
          .take(10)
          .toList(),
      artists: hive.artistsBox.values
          .where((e) => e.name.toLowerCase().contains(textLowerCase))
          .take(10)
          .toList(),
      playlists: hive.playlistsBox.values
          .where((e) => e.title.toLowerCase().contains(textLowerCase))
          .take(10)
          .toList(),
    );
  }
}
