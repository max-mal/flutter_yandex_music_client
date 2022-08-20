import 'package:get/get.dart';
import 'package:test/models/artist.dart';
import 'package:test/models/track.dart';
import 'package:hive/hive.dart';
import 'package:test/services/hive.dart';

part 'album.g.dart';

@HiveType(typeId: 5)
class Album {
  @HiveField(0)
  int id;
  @HiveField(1)
  String title;
  @HiveField(2)
  DateTime releaseDate;
  @HiveField(3)
  String coverUri;
  @HiveField(4)
  int trackCount;
  @HiveField(5)
  String genre;

  @HiveField(6)
  List<int> bestTrackIds;
  @HiveField(7)
  List<int> artistIds;

  List<Artist> artists;
  List<Track> tracks;

  Album({
    this.id = 0,
    this.title = "",
    DateTime? releaseDate,
    this.coverUri = "",
    this.trackCount = 0,
    this.genre = "",
    this.bestTrackIds = const [],
    this.artistIds = const [],
    this.artists = const [],
    this.tracks = const [],
  }) : releaseDate = DateTime.now();

  getCoverUri({int width = 200, int height = 200}) {
    return "https://${coverUri.replaceAll('%%', "${width}x$height")}";
  }

  persist() async {
    final hive = Get.find<HiveService>();
    await hive.albumsBox.put(id, this);
  }
}
