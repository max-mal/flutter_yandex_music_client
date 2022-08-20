import 'package:get/get.dart';
import 'package:test/models/artist.dart';
import 'package:test/models/track.dart';
import 'package:test/services/api.dart';
import 'package:test/services/hive.dart';

class ArtistRepo {
  final hive = Get.find<HiveService>();
  final api = Get.find<ApiService>();

  Future<Artist> get(int artistId, {bool online = false}) async {
    if (online) {
      final artist = await api.artist(artistId);
      await artist.persist();
      artist.tracks = await api.artistTracks(artistId);

      for (Track track in artist.tracks) {
        await track.persist();
      }
      return artist;
    }

    final artist = hive.artistsBox.get(artistId)!;
    artist.tracks = hive.tracksBox.values
        .where((track) => track.artistIds.contains(artistId))
        .toList();

    artist.albums = hive.albumsBox.values
        .where((album) => album.artistIds.contains(artistId))
        .toList();

    return artist;
  }
}
