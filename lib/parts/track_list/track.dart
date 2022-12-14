import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/controllers/home.dart';
import 'package:test/modals/track_options.dart';
import 'package:test/models/track.dart';
import 'package:test/parts/common/cached_network_image.dart';

class TrackListTrack extends StatelessWidget {
  final Track track;
  final Function(Track) onDownload;
  final Function onPlay;

  const TrackListTrack({
    Key? key,
    required this.track,
    required this.onDownload,
    required this.onPlay,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onPlay();
      },
      child: Row(
        children: [
          CachedNetworkImage(
            key: ValueKey(track.id),
            url: track.getCoverUri(),
            width: 100,
            height: 100,
            cacheTag: "track_cover_${track.id}",
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(track.title),
                Text("${track.artistsString} - ${track.albumsString}"),
              ],
            ),
          ),
          GetPlatform.isMobile
              ? const SizedBox()
              : Obx(
                  () => IconButton(
                    icon: Icon(
                      track.isLikedRx()
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: track.isLikedRx() ? Colors.red : Colors.black,
                    ),
                    onPressed: () {
                      final homeController = Get.find<HomeController>();
                      homeController
                          .likeTracks([track], value: !track.isLikedRx());
                    },
                  ),
                ),
          IconButton(
            icon: const Icon(
              Icons.more_vert,
            ),
            onPressed: () {
              TrackOptionsModal.open(track);
            },
          ),
        ],
      ),
    );
  }
}
