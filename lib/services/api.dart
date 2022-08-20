import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:test/models/album.dart';
import 'package:test/models/artist.dart';
import 'package:test/models/feed_event.dart';
import 'package:test/models/playlist.dart';
import 'package:test/models/search_result.dart';
import 'package:test/models/track.dart';
import 'package:test/models/track_download_info.dart';
import 'package:test/models/user.dart';
import 'package:test/utils/converters.dart';
import 'package:xml/xml.dart';
import 'package:crypto/crypto.dart';

class ApiService extends GetxService {
  String? token;
  http.Client? client;

  static const String apiHost = "api.music.yandex.net";

  Future<ApiService> init() async {
    return this;
  }

  http.Client _getClient() {
    client ??= http.Client();

    return client!;
  }

  Map<String, String> _getHeaders({bool json = false}) {
    Map<String, String> headers = {};
    if (token != null) {
      headers['Authorization'] = 'OAuth $token';
    }
    if (json) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  Future<dynamic> _request(
    String httpMethod,
    Uri uri, {
    Map<String, dynamic>? body,
    bool isJson = false,
  }) async {
    http.Response response;
    if (kDebugMode) {
      print("$httpMethod - $uri");
    }
    switch (httpMethod) {
      case 'get':
        response = await _getClient().get(uri, headers: _getHeaders());
        break;
      case 'post':
        response = await _getClient().post(
          uri,
          headers: _getHeaders(json: isJson),
          body: body,
        );
        break;
      default:
        throw "Unknown method $httpMethod";
    }
    // print(response.body);
    if (kDebugMode) {
      print("========");
    }
    return jsonDecode(response.body)['result'];
  }

  setToken(String token) {
    this.token = token;
  }

  cleanToken() {
    token = null;
  }

  Future<User> account() async {
    final response =
        await _request('get', Uri.https(apiHost, '/account/status'));
    return ConvertersUtils.userFromResponse(response['account']);
  }

  Future<List<Playlist>> generatedPlaylists() async {
    final response = await _request('get', Uri.https(apiHost, '/feed'));
    List<dynamic> playlists = response['generatedPlaylists'];

    List<Playlist> list = playlists
        .where((e) => e['ready'] == true)
        .map((e) => ConvertersUtils.playlistFromResponse(e['data']))
        .toList();

    return list;
  }

  Future<List<FeedEvent>> feedEvents() async {
    final response = await _request('get', Uri.https(apiHost, '/feed'));
    List<dynamic> eventDays = response['days'];

    List<FeedEvent> feedEvents = [];

    for (dynamic day in eventDays) {
      for (dynamic event in day['events']) {
        feedEvents.add(ConvertersUtils.eventFromResponse(event));
      }
    }

    return feedEvents;
  }

  Future<List<Track>> playlistTracks(int userId, int playlistId) async {
    final response = await _request(
        'get', Uri.https(apiHost, '/users/$userId/playlists/$playlistId'));
    List<dynamic> responseTracks = response['tracks'];

    List<Track> tracks = [];

    for (dynamic responseTrack in responseTracks) {
      tracks.add(ConvertersUtils.trackFromResponse(responseTrack['track']));
    }

    return tracks;
  }

  Future<List<TrackDownloadInfo>> trackDownloadInfo(int trackId) async {
    final response = await _request(
        'get', Uri.https(apiHost, '/tracks/$trackId/download-info'));

    List<TrackDownloadInfo> infos = [];
    for (Map<String, dynamic> item in response) {
      infos.add(TrackDownloadInfo(
        bitrate: item['bitrateInKbps'],
        codec: item['codec'],
        url: item['downloadInfoUrl'],
      ));
    }

    return infos;
  }

  trackDirectLink(TrackDownloadInfo info) async {
    final response = await http.get(Uri.parse(info.url));
    final document = XmlDocument.parse(response.body);

    if (kDebugMode) {
      print(response.body);
    }

    final root = document.getElement('download-info')!;
    final String host = root.getElement('host')?.text ?? '';
    final String path = root.getElement('path')?.text ?? '';
    final String ts = root.getElement('ts')?.text ?? '';
    final String s = root.getElement('s')?.text ?? '';

    final String sign = md5
        .convert(utf8.encode('XGRlBW9FXlekgbPrRHuSiA' + path.substring(1) + s))
        .toString();

    return "https://$host/get-mp3/$sign/$ts$path";
  }

  Future<List<int>> userLikedTrackIds(int userId) async {
    final response = await _request(
      'get',
      Uri.https(apiHost, '/users/$userId/likes/tracks'),
    );

    List<int> trackIds = [];

    for (Map<String, dynamic> item in response['library']['tracks']) {
      trackIds.add(int.parse(item['id']));
    }

    return trackIds;
  }

  Future<List<int>> userDislikedTrackIds(int userId) async {
    final response = await _request(
      'get',
      Uri.https(apiHost, '/users/$userId/dislikes/tracks'),
    );

    List<int> trackIds = [];

    for (Map<String, dynamic> item in response['library']['tracks']) {
      trackIds.add(int.parse(item['id']));
    }

    return trackIds;
  }

  userLikeTracks(int userId, List<int> trackIds, {bool value = true}) async {
    await _request(
      'post',
      Uri.https(apiHost,
          '/users/$userId/likes/tracks/${value ? 'add-multiple' : 'remove'}'),
      body: {
        'track-ids': trackIds.join(','),
      },
    );
  }

  userDislikeTracks(int userId, List<int> trackIds, {bool value = true}) async {
    await _request(
      'post',
      Uri.https(apiHost,
          '/users/$userId/dislikes/tracks/${value ? 'add-multiple' : 'remove'}'),
      body: {
        'track-ids': trackIds.join(','),
      },
    );
  }

  Future<List<Track>> tracks(List<int> trackIds) async {
    final response = await _request(
      'post',
      Uri.https(apiHost, '/tracks'),
      body: {
        'trackIds': trackIds.join(','),
      },
    );

    List<Track> tracks = [];

    for (dynamic responseTrack in response) {
      tracks.add(ConvertersUtils.trackFromResponse(responseTrack));
    }

    return tracks;
  }

  Future<Album> album(int albumId) async {
    final response = await _request(
      'get',
      Uri.https(apiHost, '/albums/$albumId/with-tracks'),
    );

    Album album = ConvertersUtils.albumFromResponse(response);

    List<Track> tracks = [];
    for (dynamic volume in response['volumes']) {
      for (dynamic responseTrack in volume) {
        tracks.add(ConvertersUtils.trackFromResponse(responseTrack));
      }
    }

    album.tracks = tracks;
    return album;
  }

  Future<Artist> artist(int artistId) async {
    final response = await _request(
      'get',
      Uri.https(apiHost, '/artists/$artistId/brief-info'),
    );

    final artist = ConvertersUtils.artistFromResponse(response['artist']);
    List<dynamic> responseAlbums = response['albums'];
    artist.albums = responseAlbums
        .map((e) => ConvertersUtils.albumFromResponse(e))
        .toList();
    return artist;
  }

  Future<List<Track>> artistTracks(int artistId) async {
    List<Track> tracks = [];
    int page = 0;
    while (true) {
      final response = await _request(
        'get',
        Uri.https(apiHost, '/artists/$artistId/tracks', {
          'page-size': 200.toString(),
          'page': page.toString(),
        }),
      );
      List<dynamic> tracksResponse = response['tracks'];
      for (dynamic track in tracksResponse) {
        tracks.add(ConvertersUtils.trackFromResponse(track));
      }
      if (tracksResponse.length < 200) {
        break;
      }
      page++;
    }
    return tracks;
  }

  Future<SearchResult> search(String text) async {
    final response = await _request(
      'get',
      Uri.https(apiHost, '/search', {
        'text': text,
        'type': 'all',
        'page': '0',
        'playlist-in-best': 'true',
        'nocorrect': 'false',
      }),
    );

    List<dynamic> tracksResponse = response['tracks']?['results'] ?? [];
    List<dynamic> artistsResponse = response['artists']?['results'] ?? [];
    List<dynamic> playlistsResponse = response['playlists']?['results'] ?? [];
    List<dynamic> albumsResponse = response['albums']?['results'] ?? [];

    return SearchResult(
      tracks: tracksResponse
          .map((e) => ConvertersUtils.trackFromResponse(e))
          .toList(),
      artists: artistsResponse
          .map((e) => ConvertersUtils.artistFromResponse(e))
          .toList(),
      playlists: playlistsResponse
          .map((e) => ConvertersUtils.playlistFromResponse(e))
          .toList(),
      albums: albumsResponse
          .map((e) => ConvertersUtils.albumFromResponse(e))
          .toList(),
      bestAlbum: response['best']['type'] == 'album'
          ? ConvertersUtils.albumFromResponse(response['best']['result'])
          : null,
      bestArtist: response['best']['type'] == 'artist'
          ? ConvertersUtils.artistFromResponse(response['best']['result'])
          : null,
      bestTrack: response['best']['type'] == 'track'
          ? ConvertersUtils.trackFromResponse(response['best']['result'])
          : null,
      bestPlaylsit: response['best']['type'] == 'playlist'
          ? ConvertersUtils.playlistFromResponse(response['best']['result'])
          : null,
    );
  }
}
