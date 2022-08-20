import 'package:test/models/album.dart';
import 'package:test/models/artist.dart';
import 'package:test/models/playlist.dart';
import 'package:test/models/track.dart';

class SearchResult {
  List<Track> tracks;
  List<Playlist> playlists;
  List<Artist> artists;
  List<Album> albums;

  Album? bestAlbum;
  Track? bestTrack;
  Artist? bestArtist;
  Playlist? bestPlaylsit;

  SearchResult({
    this.tracks = const [],
    this.playlists = const [],
    this.artists = const [],
    this.albums = const [],
    this.bestAlbum,
    this.bestArtist,
    this.bestPlaylsit,
    this.bestTrack,
  });
}
