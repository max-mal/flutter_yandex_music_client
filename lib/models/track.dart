import 'dart:io';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test/controllers/home.dart';
import 'package:test/models/album.dart';
import 'package:test/models/artist.dart';
import 'package:test/models/track_download_info.dart';
import 'package:test/services/api.dart';
import 'package:test/services/downloader.dart';
import 'package:test/services/hive.dart';

part 'track.g.dart';

@HiveType(typeId: 3)
class Track {
  @HiveField(0)
  int id;
  @HiveField(1)
  String title;
  @HiveField(2)
  Duration duration;
  @HiveField(3)
  String coverUri;
  @HiveField(4)
  bool hasLyrics;
  @HiveField(5)
  List<int> artistIds;
  @HiveField(6)
  List<int> albumIds;

  @HiveField(7)
  String? localPath;

  List<Artist> artists;
  List<Album> albums;

  String? directLink;
  DateTime? directLinkTime;

  Track({
    this.id = 0,
    this.title = "",
    this.duration = const Duration(),
    this.coverUri = "",
    this.hasLyrics = false,
    this.artistIds = const [],
    this.albumIds = const [],
    this.localPath,
    this.artists = const [],
    this.albums = const [],
  });

  Future<String> getDownloadUrl() async {
    if (directLink != null &&
        DateTime.now().difference(directLinkTime ?? DateTime.now()).inMinutes <
            60) {
      return directLink!;
    }

    final api = Get.find<ApiService>();
    final downloadInfos = await api.trackDownloadInfo(id);

    for (TrackDownloadInfo item in downloadInfos) {
      if (item.bitrate == 192) {
        directLink = await api.trackDirectLink(item);
        directLinkTime = DateTime.now();
        return directLink!;
      }
    }

    directLink = await api.trackDirectLink(downloadInfos.first);
    directLinkTime = DateTime.now();
    return directLink!;
  }

  persist() async {
    final hive = Get.find<HiveService>();
    await hive.tracksBox.put(id, this);
    for (Album album in albums) {
      await hive.albumsBox.put(album.id, album);
    }
    for (Artist artist in artists) {
      await hive.artistsBox.put(artist.id, artist);
    }
  }

  createLocalPath() async {
    final downlader = Get.find<DownloaderService>();
    final downloadsDir = downlader.tracksDir;
    return '$downloadsDir/track_$id.mp3';
  }

  bool isDownloaded() {
    final hive = Get.find<HiveService>();
    return hive.downloadedTracks.get(id, defaultValue: false) ?? false;
  }

  bool isDownloadedRx() {
    final hive = Get.find<HiveService>();
    return hive.rxDownloadedTracks.where((e) => e.id == id).isNotEmpty;
  }

  bool isDownloadEnqueuedRx() {
    final downloader = Get.find<DownloaderService>();
    return downloader.tracksQueue.where((e) => e.id == id).isNotEmpty;
  }

  bool isLikedRx() {
    final controller = Get.find<HomeController>();
    return controller.likedTracks.where((e) => e.id == id).isNotEmpty;
  }

  bool isDislikedRx() {
    final controller = Get.find<HomeController>();
    return controller.dislikedTracks.where((e) => e.id == id).isNotEmpty;
  }

  String get artistsString => artists.map((e) => e.name).join(', ');
  String get albumsString => albums.map((e) => e.title).join(', ');

  String getCoverUri({int width = 200, int height = 200}) {
    return "https://${coverUri.replaceAll('%%', "${width}x$height")}";
  }

  loadArtists() {
    final hive = Get.find<HiveService>();
    artists = [];
    for (int artistId in artistIds) {
      artists.add(hive.artistsBox.get(artistId)!);
    }
  }

  loadAlbums() {
    final hive = Get.find<HiveService>();
    albums = [];
    for (int albumId in albumIds) {
      albums.add(hive.albumsBox.get(albumId)!);
    }
  }

  Track withRelations() {
    loadAlbums();
    loadArtists();
    return this;
  }
}
