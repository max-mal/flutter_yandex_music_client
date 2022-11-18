import 'package:test/models/album.dart';
import 'package:test/models/artist.dart';
import 'package:test/models/feed_event.dart';
import 'package:test/models/playlist.dart';
import 'package:test/models/track.dart';
import 'package:test/models/user.dart';

class ConvertersUtils {
  static User userFromResponse(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      firstName: map['firstName'],
      secondName: map['secondName'],
      fullName: map['fullName'],
      login: map['login'],
      registeredAt: DateTime.tryParse(map['registeredAt']),
    );
  }

  static Playlist playlistFromResponse(Map<String, dynamic> map) {
    return Playlist(
      uid: map['uid'],
      title: map['title'],
      description: map['description'] ?? "",
      kind: map['kind'],
      trackCount: map['trackCount'],
      coverUri: map['cover']?['uri'] ?? map['ogImage'].toString(),
      backgroundImageUrl: map['backgroundImageUrl'].toString(),
      backgroundVideoUrl: map['backgroundVideoUrl'].toString(),
      ownerLogin: map['owner']['login'],
      ownerName: map['owner']['name'],
      ownerUid: map['owner']['uid'],
    );
  }

  static Track trackFromResponse(Map<String, dynamic> map) {
    return Track(
      id: map['id'].toString(),
      title: map['title'],
      duration: Duration(milliseconds: map['durationMs'] ?? 0),
      coverUri: map['coverUri'] ?? (map['cover']?['uri'] ?? ""),
      hasLyrics: map['lyricsAvailable'] ?? false,
      artistIds: List<int>.from(map['artists'].map((e) => e['id']).toList()),
      albumIds: List<int>.from(map['albums'].map((e) => e['id']).toList()),
      artists: List<Artist>.from(
          map['artists'].map((e) => artistFromResponse(e)).toList()),
      albums: List<Album>.from(
          map['albums'].map((e) => albumFromResponse(e)).toList()),
    );
  }

  static Artist artistFromResponse(Map<String, dynamic> map) {
    return Artist(
      id: int.parse(map['id'].toString()),
      name: map['name'],
      coverUri: map['cover']?['uri'] ?? "",
    );
  }

  static Album albumFromResponse(Map<String, dynamic> map) {
    return Album(
      id: map['id'],
      title: map['title'],
      releaseDate: map['releaseDate'] == null
          ? DateTime.now()
          : DateTime.tryParse(map['releaseDate'].toString()),
      coverUri: map['coverUri'],
      trackCount: map['trackCount'],
      genre: map['genre'].toString(),
      bestTrackIds: List<int>.from(map['bests']),
      artistIds: List<int>.from(map['artists'].map((e) => e['id']).toList()),
      artists: List<Artist>.from(
          map['artists'].map((e) => artistFromResponse(e)).toList()),
    );
  }

  static FeedEvent eventFromResponse(Map<String, dynamic> map) {
    final event = FeedEvent(
      id: map['id'],
      type: map['type'],
      titleParts: map['title'],
      tracks: List<dynamic>.from(map['tracks'] ?? [])
          .map((e) => ConvertersUtils.trackFromResponse(e))
          .toList(),
    );

    if (event.type == 'recommended-artists-with-artists-from-history') {
      event.artists = List<dynamic>.from(map['artistsWithArtistsFromHistory'])
          .map((e) => ConvertersUtils.artistFromResponse(e['artist']))
          .toList();
    }

    if (event.type == 'recommended-similar-artists') {
      event.artists = List<dynamic>.from(map['similarArtists'])
          .map((e) => ConvertersUtils.artistFromResponse(e['artist']))
          .toList();
    }

    if (map['artists'] != null) {
      event.artists = List<dynamic>.from(map['artists'])
          .map((e) => ConvertersUtils.artistFromResponse(e['artist']))
          .toList();
    }
    return event;
  }
}
