import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/controllers/home.dart';
import 'package:test/modals/track_options.dart';
import 'package:test/pages/playing.dart';
import 'package:test/parts/common/cached_network_image.dart';
import 'package:test/services/audio_control.dart';

class PlayerBar extends StatelessWidget {
  PlayerBar({Key? key}) : super(key: key);

  final audioControl = Get.find<AudioControlService>();
  final homeController = Get.find<HomeController>();

  double _bottomPadding(context) {
    final padding = MediaQuery.of(context).viewPadding.bottom;
    if (padding >= 15) {
      return padding - 15;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.lightBlue,
          padding: const EdgeInsets.all(10.0),
          child: Padding(
            padding: EdgeInsets.only(bottom: _bottomPadding(context)),
            child: Obx(
              () => Row(
                mainAxisAlignment: GetPlatform.isMobile
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  audioControl.currentTrack.value == null
                      ? Container(
                          width: 40,
                          height: 40,
                          color: Colors.black.withOpacity(0.4),
                        )
                      : InkWell(
                          onTap: () {
                            PlayingPage.open();
                          },
                          child: CachedNetworkImage(
                            key: ValueKey(
                                "track_cover_${audioControl.currentTrack.value!.id}"),
                            url: audioControl.currentTrack.value!.getCoverUri(),
                            width: 40,
                            height: 40,
                            cacheTag:
                                "track_cover_${audioControl.currentTrack.value!.id}",
                          ),
                        ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () {
                      audioControl.prevTrack();
                    },
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(audioControl.isPlaying.value
                        ? Icons.pause
                        : Icons.play_arrow),
                    onPressed: () {
                      if (audioControl.isPlaying.value) {
                        audioControl.pause();
                      } else {
                        audioControl.play();
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: () {
                      audioControl.nextTrack();
                    },
                  ),
                  const SizedBox(width: 10),
                  GetPlatform.isMobile
                      ? const SizedBox()
                      : SizedBox(
                          width: 80,
                          child: Text(
                              "${audioControl.position.value.inSeconds} / ${audioControl.trackDuration.value.inSeconds}"),
                        ),
                  GetPlatform.isMobile
                      ? const SizedBox()
                      : Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  audioControl.currentTrack.value?.title ?? ""),
                              Text(audioControl
                                      .currentTrack.value?.artistsString ??
                                  ""),
                            ],
                          ),
                        ),
                  audioControl.currentTrack.value == null ||
                          GetPlatform.isMobile
                      ? const SizedBox()
                      : IconButton(
                          icon: Icon(
                            audioControl.currentTrack.value!.isLikedRx()
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: audioControl.currentTrack.value!.isLikedRx()
                                ? Colors.red
                                : Colors.black,
                          ),
                          onPressed: () {
                            final homeController = Get.find<HomeController>();
                            homeController.likeTracks(
                                [audioControl.currentTrack.value!],
                                value: !audioControl.currentTrack.value!
                                    .isLikedRx());
                          },
                        ),
                  audioControl.currentTrack.value == null
                      ? const SizedBox()
                      : IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            TrackOptionsModal.open(
                                audioControl.currentTrack.value!);
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          child: Obx(
            () => _slider(),
          ),
        ),
      ],
    );
  }

  _slider() {
    try {
      return SliderTheme(
        data: SliderThemeData(
          overlayShape: SliderComponentShape.noOverlay,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
        ),
        child: Slider(
          value: audioControl.position.value.inMicroseconds.toDouble(),
          onChanged: (value) {
            audioControl.seek(Duration(microseconds: value.toInt()));
          },
          min: 0,
          max: audioControl.position.value > audioControl.trackDuration.value
              ? audioControl.position.value.inMicroseconds.toDouble()
              : audioControl.trackDuration.value.inMicroseconds.toDouble(),
          thumbColor: Colors.grey,
          activeColor: Colors.grey,
          inactiveColor: Colors.black.withOpacity(0.3),
        ),
      );
    } catch (e) {
      return const SizedBox();
    }
  }
}
