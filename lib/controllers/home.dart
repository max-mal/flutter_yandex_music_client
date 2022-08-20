import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:test/models/album.dart';
import 'package:test/models/artist.dart';
import 'package:test/models/feed_event.dart';
import 'package:test/models/playlist.dart';
import 'package:test/models/search_result.dart';
import 'package:test/models/track.dart';
import 'package:test/models/user.dart';
import 'package:test/pages/splash.dart';
import 'package:test/pages/track_list.dart';
import 'package:test/repos/album.dart';
import 'package:test/repos/artist.dart';
import 'package:test/repos/events.dart';
import 'package:test/repos/generated_playlists.dart';
import 'package:test/repos/search.dart';
import 'package:test/repos/tracks.dart';
import 'package:test/repos/user.dart';
import 'package:test/services/api.dart';
import 'package:test/services/audio_control.dart';
import 'package:test/services/downloader.dart';
import 'package:test/services/hive.dart';
import 'package:test/use_cases/login.dart';

class HomeController extends GetxController {
  final hive = Get.find<HiveService>();
  final audioControl = Get.find<AudioControlService>();
  final downloader = Get.find<DownloaderService>();
  final userRepo = UserRepository();
  final tracksRepo = TracksRepo();
  final albumRepo = AlbumRepo();
  final artistRepo = ArtistRepo();
  final searchRepo = SearchRepo();
  final eventsRepo = EventsRepo();
  final generatedPlaylistsRepo = GeneratedPlaylistsRepo();
  final api = Get.find<ApiService>();

  Rx<User> user = Rx<User>(User());
  RxList<Playlist> generatedPlaylists = RxList<Playlist>([]);
  RxList<Track> likedTracks = RxList<Track>([]);
  RxList<Track> dislikedTracks = RxList<Track>([]);
  RxList<FeedEvent> feedEvents = RxList<FeedEvent>([]);

  RxBool online = true.obs;

  @override
  void onReady() {
    initialize();
    super.onReady();
  }

  initialize() async {
    try {
      user(await userRepo.get(online: true));
    } catch (e) {
      online(false);
      user(await userRepo.get(online: online.value));
      if (kDebugMode) {
        print(e);
      }
    }
    loadHomePage();
  }

  loadHomePage({bool notification = false}) {
    _loadPlaylists();
    _loadLikedTracks();
    _loadDislikedTracks();
    _loadFeedEvents();

    if (notification) {
      Get.snackbar('Выполняется', 'Получаю информацию');
    }
  }

  _loadPlaylists() async {
    generatedPlaylists(await generatedPlaylistsRepo.get(online: online.value));
  }

  _loadLikedTracks() async {
    likedTracks(await tracksRepo.liked(online: online.value));
  }

  _loadDislikedTracks() async {
    dislikedTracks(await tracksRepo.disliked(online: online.value));
  }

  _loadFeedEvents() async {
    feedEvents(await eventsRepo.get(online: online.value));
  }

  onPlaylistClick(Playlist playlist) {
    Get.to(
      () => TrackListPage(
        title: playlist.title,
        description: playlist.description,
        tracksFuture: tracksRepo.getFromPlaylist(
          playlist.ownerUid,
          playlist.kind,
          online: online.value,
        ),
      ),
    );
  }

  playTrack(Track track, List<Track> playlist) {
    audioControl.playTrack(track, playlist);
  }

  logout() async {
    await LoginUseCase().logout();
    Get.offAll(() => const SplashPage());
  }

  onLikedClick() {
    Get.to(
      () => TrackListPage(
        title: 'Мне нравится',
        description: '',
        tracksFuture: tracksRepo.liked(
          online: online.value,
        ),
      ),
    );
  }

  onDownloadedClick() {
    Get.to(
      () => TrackListPage(
        title: 'Загруженное',
        description: '',
        tracksFuture: tracksRepo.downloaded(),
      ),
    );
  }

  downloadTracks(List<Track> tracks) {
    downloader.downloadTracks(tracks);
  }

  setOnline(bool value) {
    online(value);
    audioControl.setOnline(value);
  }

  likeTracks(List<Track> tracks, {bool value = true}) async {
    try {
      likedTracks(await tracksRepo.likeTracks(tracks, value: value));
      Get.snackbar(
        'Готово!',
        value ? 'Трек добавлен в избранное' : 'Трек удален из избранного',
      );
      dislikedTracks(await tracksRepo.disliked(online: online.value));
    } catch (e) {
      Get.snackbar('Ошибка', e.toString());
    }
  }

  dislikeTracks(List<Track> tracks, {bool value = true}) async {
    try {
      dislikedTracks(await tracksRepo.dislikeTracks(tracks, value: value));
      Get.snackbar(
        'Готово!',
        value
            ? 'Поставлена отметка "Не нравится"'
            : 'Удалена отметка "Не нравится"',
      );
      likedTracks(await tracksRepo.liked(online: online.value));
    } catch (e) {
      Get.snackbar('Ошибка', e.toString());
    }
  }

  Future<Album> getAlbum(int albumId) async {
    return await albumRepo.get(albumId, online: online.value);
  }

  Future<Artist> getArtist(int artistId) async {
    return await artistRepo.get(artistId, online: online.value);
  }

  Future<SearchResult> search(String text) async {
    return await searchRepo.search(text);
  }
}
