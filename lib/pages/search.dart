import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/controllers/home.dart';
import 'package:test/controllers/search.dart';
import 'package:test/pages/album.dart';
import 'package:test/pages/artist.dart';
import 'package:test/parts/player/player_bar.dart';
import 'package:test/parts/search/item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();

  static open() async {
    await Get.to(() => const SearchPage());
  }
}

class _SearchPageState extends State<SearchPage> {
  final controller = Get.put(AppSearchController());
  final homeController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    decoration: const InputDecoration(
                      hintText: 'Поиск',
                    ),
                    autofocus: true,
                    onSubmitted: (_) {
                      controller.onSearch();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    controller.onSearch();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Obx(
                () => controller.result.value == null
                    ? const SizedBox()
                    : Column(
                        children: [
                          _best(),
                          _list('Треки', _tracks()),
                          _list('Исполнители', _artists()),
                          _list('Альбомы', _albums()),
                          _list('Плейлисты', _playlists()),
                        ],
                      ),
              ),
            ),
          ),
          PlayerBar(),
        ],
      ),
    );
  }

  _list(String title, List<Widget> items) {
    if (items.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 5),
        ...items,
      ],
    );
  }

  List<Widget> _tracks() {
    return controller.result.value!.tracks
        .map<Widget>(
          (e) => SearchItem(
            title: e.title,
            coverUri: e.getCoverUri(),
            cacheTag: "track_cover_${e.id}",
            onTap: () {
              homeController.playTrack(e, [e]);
            },
          ),
        )
        .toList();
  }

  List<Widget> _albums() {
    return controller.result.value!.albums
        .map<Widget>(
          (e) => SearchItem(
            title: e.title,
            coverUri: e.getCoverUri(),
            cacheTag: "album_${e.id}",
            onTap: () {
              AlbumPage.open(e.id);
            },
          ),
        )
        .toList();
  }

  List<Widget> _artists() {
    return controller.result.value!.artists
        .map<Widget>(
          (e) => SearchItem(
            title: e.name,
            coverUri: e.getCoverUri(),
            cacheTag: "artist_${e.id}",
            onTap: () {
              ArtistPage.open(e.id);
            },
          ),
        )
        .toList();
  }

  List<Widget> _playlists() {
    return controller.result.value!.playlists
        .map<Widget>(
          (e) => SearchItem(
            title: e.title,
            coverUri: e.getCoverUri(),
            cacheTag: "playlist_${e.uid}_${e.kind}",
            onTap: () {
              homeController.onPlaylistClick(e);
            },
          ),
        )
        .toList();
  }

  Widget _best() {
    Widget? bestItem;
    if (controller.result.value?.bestTrack != null) {
      final item = controller.result.value!.bestTrack!;
      bestItem = SearchItem(
        title: item.title,
        coverUri: item.getCoverUri(),
        cacheTag: "track_cover_${item.id}",
        onTap: () {
          homeController.playTrack(item, [item]);
        },
      );
    }

    if (controller.result.value?.bestAlbum != null) {
      final item = controller.result.value!.bestAlbum!;
      bestItem = SearchItem(
        title: item.title,
        coverUri: item.getCoverUri(),
        cacheTag: "album_${item.id}",
        onTap: () {
          AlbumPage.open(item.id);
        },
      );
    }

    if (controller.result.value?.bestArtist != null) {
      final item = controller.result.value!.bestArtist!;
      bestItem = SearchItem(
        title: item.name,
        coverUri: item.getCoverUri(),
        cacheTag: "artist_${item.id}",
        onTap: () {
          ArtistPage.open(item.id);
        },
      );
    }

    if (controller.result.value?.bestPlaylsit != null) {
      final item = controller.result.value!.bestPlaylsit!;
      bestItem = SearchItem(
        title: item.title,
        coverUri: item.getCoverUri(),
        cacheTag: "playlist_${item.uid}_${item.kind}",
        onTap: () {
          homeController.onPlaylistClick(item);
        },
      );
    }

    if (bestItem != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Лучший вариант',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          bestItem,
        ],
      );
    }

    return const SizedBox();
  }
}
