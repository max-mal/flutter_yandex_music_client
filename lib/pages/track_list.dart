import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/controllers/home.dart';
import 'package:test/models/track.dart';
import 'package:test/parts/common/counter_icon_button.dart';
import 'package:test/parts/player/player_bar.dart';
import 'package:test/parts/track_list/track.dart';
import 'package:test/services/downloader.dart';

class TrackListPage extends StatefulWidget {
  final Future<List<Track>> tracksFuture;
  final String title;
  final String description;

  const TrackListPage({
    Key? key,
    required this.tracksFuture,
    this.title = "",
    this.description = "",
  }) : super(key: key);

  @override
  State<TrackListPage> createState() => _TrackListPageState();
}

class _TrackListPageState extends State<TrackListPage> {
  final homeController = Get.find<HomeController>();
  final downloader = Get.find<DownloaderService>();
  List<Track> tracksList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            Center(
              child: Obx(
                () => CounterIconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    homeController.downloadTracks(tracksList);
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
              child: FutureBuilder(
                future: widget.tracksFuture,
                builder: (context, AsyncSnapshot<List<Track>> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Icon(Icons.error),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  List<Track> tracks = snapshot.data!;
                  tracksList = tracks;

                  return ListView.builder(
                    itemBuilder: (context, index) => trackItem(
                      tracks[index],
                      () {
                        homeController.playTrack(tracks[index], tracks);
                      },
                    ),
                    itemCount: tracks.length,
                  );
                },
              ),
            ),
            PlayerBar(),
          ],
        ));
  }

  trackItem(Track track, Function onPlay) {
    return TrackListTrack(
      track: track,
      onPlay: onPlay,
      onDownload: (track) {
        homeController.downloadTracks([
          track,
        ]);
      },
    );
  }
}
