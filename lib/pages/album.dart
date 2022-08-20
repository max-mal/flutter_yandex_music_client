import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/controllers/home.dart';
import 'package:test/models/album.dart';
import 'package:test/parts/common/cached_network_image.dart';
import 'package:test/parts/common/counter_icon_button.dart';
import 'package:test/parts/player/player_bar.dart';
import 'package:test/parts/track_list/track.dart';
import 'package:test/services/downloader.dart';

class AlbumPage extends StatefulWidget {
  final int albumId;

  const AlbumPage({
    Key? key,
    required this.albumId,
  }) : super(key: key);

  @override
  State<AlbumPage> createState() => _AlbumPageState();

  static open(int albumId) async {
    await Get.to(() => AlbumPage(albumId: albumId));
  }
}

class _AlbumPageState extends State<AlbumPage> {
  late Album album;
  bool loading = true;
  bool error = false;

  final homeController = Get.find<HomeController>();
  final downloader = Get.find<DownloaderService>();

  @override
  void initState() {
    homeController.getAlbum(widget.albumId).then((value) {
      if (mounted) {
        setState(() {
          album = value;
          loading = false;
        });
      }
    }).catchError((_e) {
      if (kDebugMode) {
        print(_e);
      }
      if (mounted) {
        setState(() {
          error = true;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: error
              ? const Icon(Icons.error)
              : const CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(album.title),
        elevation: 0,
        actions: [
          Center(
            child: Obx(
              () => CounterIconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  homeController.downloadTracks(album.tracks);
                },
                counter: downloader.tracksQueue.length,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 30),
                    color: Colors.blue,
                    child: Center(
                      child: CachedNetworkImage(
                        url: album.getCoverUri(),
                        width: 200,
                        height: 200,
                        cacheTag: 'album_${album.id}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => TrackListTrack(
                      track: album.tracks[index],
                      onDownload: (_) =>
                          homeController.downloadTracks([album.tracks[index]]),
                      onPlay: () => homeController.playTrack(
                          album.tracks[index], album.tracks),
                    ),
                    itemCount: album.tracks.length,
                  ),
                ],
              ),
            ),
          ),
          PlayerBar(),
        ],
      ),
    );
  }
}
