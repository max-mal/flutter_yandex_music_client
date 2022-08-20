import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/controllers/home.dart';
import 'package:test/models/feed_event.dart';
import 'package:test/pages/artist.dart';
import 'package:test/parts/common/cached_network_image.dart';
import 'package:test/parts/track_list/track.dart';

class HomeFeedItem extends StatelessWidget {
  final FeedEvent event;

  const HomeFeedItem({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
                text: event.titleParts.first['text'].toString(),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    _onSpanTap(event.titleParts.first);
                  },
                children: event.titleParts
                    .getRange(1, event.titleParts.length)
                    .map(
                      (e) => TextSpan(
                        text: e['text'].toString(),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _onSpanTap(e);
                          },
                      ),
                    )
                    .toList()),
          ),
          const SizedBox(height: 20),
          event.artists.isEmpty
              ? const SizedBox()
              : SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => InkWell(
                      onTap: () => ArtistPage.open(event.artists[index].id),
                      child: Tooltip(
                        message: event.artists[index].name,
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: CachedNetworkImage(
                            url: event.artists[index].getCoverUri(),
                            cacheTag: "artist_${event.artists[index].id}",
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                    ),
                    itemCount: event.artists.length,
                  ),
                ),
          event.tracks.isEmpty
              ? const SizedBox()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => TrackListTrack(
                    track: event.tracks[index],
                    onDownload: (_) {
                      final homeController = Get.find<HomeController>();
                      homeController.downloadTracks([event.tracks[index]]);
                    },
                    onPlay: () {
                      final homeController = Get.find<HomeController>();
                      homeController.playTrack(
                          event.tracks[index], event.tracks);
                    },
                  ),
                  itemCount: event.tracks.length,
                ),
        ],
      ),
    );
  }

  _onSpanTap(Map<String, dynamic> e) {
    if (e['type'] == 'artist') {
      ArtistPage.open(e['id']);
    }
  }
}
