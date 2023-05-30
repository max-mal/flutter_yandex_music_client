import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
// ignore: unnecessary_import
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test/models/album.dart';
import 'package:test/models/artist.dart';
import 'package:test/models/playlist.dart';
import 'package:test/models/track.dart';
import 'package:test/models/user.dart';
import 'package:test/utils/path.dart';

class HiveService extends GetxService {
  late Box<User> userBox;
  late Box<Playlist> generatedPlaylists;
  late Box<Playlist> userPlaylists;
  late Box<Track> tracksBox;
  late Box<Album> albumsBox;
  late Box<Artist> artistsBox;
  late Box<List<String>> playlistTracks;
  late Box<bool> downloadedTracks;
  late Box<Playlist> playlistsBox;
  RxList<Track> rxDownloadedTracks = RxList<Track>();

  Future<HiveService> init() async {
    final appDocDir = await PathUtil.getApplicationDirectory();
    if (kDebugMode) {
      print('Will init in ${appDocDir.path}');
    }
    await Hive.initFlutter(appDocDir.path);

    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(PlaylistAdapter());
    Hive.registerAdapter(TrackAdapter());
    Hive.registerAdapter(AlbumAdapter());
    Hive.registerAdapter(ArtistAdapter());
    Hive.registerAdapter(DurationAdapter());

    userBox = await Hive.openBox<User>('user');
    generatedPlaylists = await Hive.openBox<Playlist>('generatedPlaylists');
    playlistsBox = await Hive.openBox<Playlist>('playlists');
    tracksBox = await Hive.openBox<Track>('tracks');
    albumsBox = await Hive.openBox<Album>('albums');
    artistsBox = await Hive.openBox<Artist>('artists');
    playlistTracks = await Hive.openBox('playlistTracks');
    downloadedTracks = await Hive.openBox('downloadedTracks');
    userPlaylists = await Hive.openBox<Playlist>('userPlaylists');

    for (String id in downloadedTracks.keys) {
      var track = tracksBox.get(id);
      if (track == null) {
        downloadedTracks.delete(id);
        continue;
      }
      rxDownloadedTracks.add(tracksBox.get(id)!);
    }

    return this;
  }

  cleanUp() async {
    await userBox.clear();
    await generatedPlaylists.clear();
    await tracksBox.clear();
    await albumsBox.clear();
    await artistsBox.clear();
    await playlistTracks.clear();
    await downloadedTracks.clear();
    await userPlaylists.clear();
  }
}

class DurationAdapter extends TypeAdapter<Duration> {
  @override
  void write(BinaryWriter writer, Duration obj) =>
      writer.writeInt(obj.inMicroseconds);

  @override
  Duration read(BinaryReader reader) =>
      Duration(microseconds: reader.readInt());

  @override
  int get typeId => 100;
}
