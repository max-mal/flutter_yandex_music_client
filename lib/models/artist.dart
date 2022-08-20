import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:test/models/album.dart';
import 'package:test/models/track.dart';
import 'package:test/services/hive.dart';

part 'artist.g.dart';

@HiveType(typeId: 4)
class Artist extends HiveObject {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String coverUri;

  List<Track> tracks;
  List<Album> albums;

  Artist({
    this.id = 0,
    this.name = "",
    this.coverUri = "",
    this.tracks = const [],
    this.albums = const [],
  });

  persist() async {
    final hive = Get.find<HiveService>();
    await hive.artistsBox.put(id, this);
  }

  getCoverUri({int width = 200, int height = 200}) {
    return "https://${coverUri.replaceAll('%%', "${width}x$height")}";
  }
}
