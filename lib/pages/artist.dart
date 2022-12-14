import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/controllers/home.dart';
import 'package:test/models/artist.dart';
import 'package:test/pages/album.dart';
import 'package:test/parts/artist/album.dart';
import 'package:test/parts/common/cached_network_image.dart';
import 'package:test/parts/common/counter_icon_button.dart';
import 'package:test/parts/player/player_bar.dart';
import 'package:test/parts/track_list/track.dart';
import 'package:test/services/downloader.dart';

class ArtistPage extends StatefulWidget {
  final int artistId;

  const ArtistPage({
    Key? key,
    required this.artistId,
  }) : super(key: key);

  @override
  State<ArtistPage> createState() => _ArtistPageState();

  static open(int artistId) async {
    await Get.to(() => ArtistPage(artistId: artistId));
  }
}

class _ArtistPageState extends State<ArtistPage> {
  late Artist artist;
  bool loading = true;
  bool error = false;

  final homeController = Get.find<HomeController>();
  final downloader = Get.find<DownloaderService>();

  @override
  void initState() {
    homeController.getArtist(widget.artistId).then((value) {
      if (mounted) {
        setState(() {
          artist = value;
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
        title: Text(artist.name),
        elevation: 0,
        actions: [
          Center(
            child: Obx(
              () => CounterIconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  homeController.downloadTracks(artist.tracks);
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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 30),
                    margin: const EdgeInsets.only(bottom: 20),
                    color: Colors.blue,
                    child: Center(
                      child: CachedNetworkImage(
                        url: artist.getCoverUri(),
                        width: 200,
                        height: 200,
                        cacheTag: 'artist_${artist.id}',
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 166,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.touch,
                        },
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => ArtistAlbum(
                          album: artist.albums[index],
                          onTap: (_album) {
                            AlbumPage.open(_album.id);
                          },
                        ),
                        itemCount: artist.albums.length,
                      ),
                    ),
                  ),
                ),
                SliverFixedExtentList(
                  itemExtent: 100.0,
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) => TrackListTrack(
                      track: artist.tracks[index],
                      onDownload: (_) =>
                          homeController.downloadTracks([artist.tracks[index]]),
                      onPlay: () => homeController.playTrack(
                          artist.tracks[index], artist.tracks),
                    ),
                    childCount: artist.tracks.length,
                  ),
                ),
              ],
            ),
          ),
          PlayerBar(),
        ],
      ),
    );
  }
}
