import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/controllers/home.dart';
import 'package:test/models/feed_event.dart';
import 'package:test/pages/artist.dart';
import 'package:test/parts/common/cached_network_image.dart';
import 'package:test/parts/track_list/track.dart';

class HomeFeedItemTitle extends StatelessWidget {
  final FeedEvent event;

  const HomeFeedItemTitle({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        right: 8,
        left: 8,
        bottom: 28,
      ),
      child: RichText(
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
    );
  }

  _onSpanTap(Map<String, dynamic> e) {
    if (kDebugMode) {
      print(e);
    }
    if (e['type'] == 'artist') {
      ArtistPage.open(e['id']);
    }
  }
}

class HomeFeedItemArtists extends StatelessWidget {
  final FeedEvent event;

  const HomeFeedItemArtists({
    Key? key,
    required this.event,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => InkWell(
          onTap: () => ArtistPage.open(event.artists[index].id),
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(8.0),
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                ),
                child: CachedNetworkImage(
                  key: ValueKey(event.artists[index].getCacheTag()),
                  url: event.artists[index].getCoverUri(),
                  cacheTag: event.artists[index].getCacheTag(),
                  width: 100,
                  height: 100,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 8.0,
                    right: 8,
                    left: 8,
                    bottom: 12,
                  ),
                  padding: const EdgeInsets.all(2.0),
                  color: Colors.black.withOpacity(0.5),
                  child: Text(
                    event.artists[index].name,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        itemCount: event.artists.length,
      ),
    );
  }
}

class HomeFeedItem extends StatelessWidget {
  final FeedEvent event;

  const HomeFeedItem({
    Key? key,
    required this.event,
  }) : super(key: key);

  static List<Widget> asSliverList(FeedEvent event) {
    List<Widget> slivers = [];

    slivers.add(
      SliverToBoxAdapter(
        child: HomeFeedItemTitle(
          event: event,
        ),
      ),
    );

    if (event.artists.isNotEmpty) {
      slivers.add(SliverToBoxAdapter(
        child: HomeFeedItemArtists(event: event),
      ));
    }

    if (event.tracks.isNotEmpty) {
      slivers.add(SliverFixedExtentList(
        itemExtent: 100.0,
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) => TrackListTrack(
            track: event.tracks[index],
            onDownload: (_) {
              final homeController = Get.find<HomeController>();
              homeController.downloadTracks([event.tracks[index]]);
            },
            onPlay: () {
              final homeController = Get.find<HomeController>();
              homeController.playTrack(event.tracks[index], event.tracks);
            },
          ),
          childCount: event.tracks.length,
        ),
      ));
    }
    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        HomeFeedItemTitle(
          event: event,
        ),
        event.artists.isEmpty
            ? const SizedBox()
            : HomeFeedItemArtists(event: event),
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
                    homeController.playTrack(event.tracks[index], event.tracks);
                  },
                ),
                itemCount: event.tracks.length,
              ),
      ],
    );
  }
}
