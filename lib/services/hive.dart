import 'package:get/get.dart';
// ignore: unnecessary_import
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test/models/album.dart';
import 'package:test/models/artist.dart';
import 'package:test/models/playlist.dart';
import 'package:test/models/track.dart';
import 'package:test/models/user.dart';

class HiveService extends GetxService {
  late Box<User> userBox;
  late Box<Playlist> generatedPlaylists;
  late Box<Track> tracksBox;
  late Box<Album> albumsBox;
  late Box<Artist> artistsBox;
  late Box<List<int>> playlistTracks;
  late Box<bool> downloadedTracks;
  late Box<Playlist> playlistsBox;
  RxList<Track> rxDownloadedTracks = RxList<Track>();

  Future<HiveService> init() async {
    await Hive.initFlutter();
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

    for (int id in downloadedTracks.keys) {
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
