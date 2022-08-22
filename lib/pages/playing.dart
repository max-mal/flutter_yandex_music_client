import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/controllers/home.dart';
import 'package:test/modals/track_options.dart';
import 'package:test/parts/common/cached_network_image.dart';
import 'package:test/parts/player/player_view.dart';
import 'package:test/parts/track_list/track.dart';
import 'package:test/services/audio_control.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage({Key? key}) : super(key: key);

  static open() async {
    await Get.to(() => const PlayingPage());
  }

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> {
  final audioControl = Get.find<AudioControlService>();

  final homeController = Get.find<HomeController>();
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('Сейчас играет'),
      ),
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: _playing(),
          ),
          Obx(
            () => SliverFixedExtentList(
              itemExtent: 100.0,
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) => TrackListTrack(
                  track: audioControl.tracksList[index],
                  onDownload: (_) => homeController
                      .downloadTracks([audioControl.tracksList[index]]),
                  onPlay: () => homeController.playTrack(
                    audioControl.tracksList[index],
                    audioControl.tracksList,
                  ),
                ),
                childCount: audioControl.tracksList.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _playing() {
    return Stack(
      children: [
        SizedBox(
          height: Get.height - 55,
        ),
        PlayerView(audioControl: audioControl),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: InkWell(
              onTap: () {
                scrollController.animateTo(
                  Get.height - 55,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linear,
                );
              },
              child: const Icon(
                Icons.arrow_drop_down,
                color: Colors.grey,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
