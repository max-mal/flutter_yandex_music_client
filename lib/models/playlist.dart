import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:test/services/hive.dart';

part 'playlist.g.dart';

@HiveType(typeId: 2)
class Playlist {
  @HiveField(0)
  int uid;
  @HiveField(1)
  int kind;
  @HiveField(2)
  String title;
  @HiveField(3)
  String description;
  @HiveField(4)
  int trackCount;

  @HiveField(5)
  String coverUri;
  @HiveField(6)
  String backgroundVideoUrl;
  @HiveField(7)
  String backgroundImageUrl;

  @HiveField(8)
  int ownerUid;
  @HiveField(9)
  String ownerLogin;
  @HiveField(10)
  String ownerName;

  Playlist({
    this.uid = 0,
    this.kind = 0,
    this.title = "",
    this.description = "",
    this.trackCount = 0,
    this.coverUri = "",
    this.backgroundImageUrl = "",
    this.backgroundVideoUrl = "",
    this.ownerLogin = "",
    this.ownerName = "",
    this.ownerUid = 0,
  });

  String getCoverUri({int width = 200, int height = 200}) {
    return "https://" + coverUri.replaceAll('%%', '${width}x$height');
  }

  persist() async {
    final hive = Get.find<HiveService>();
    await hive.playlistsBox.put("$uid/$kind", this);
  }
}
