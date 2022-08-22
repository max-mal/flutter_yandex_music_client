import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/modals/track_options.dart';
import 'package:test/parts/common/cached_network_image.dart';
import 'package:test/services/audio_control.dart';

class PlayerView extends StatelessWidget {
  final AudioControlService audioControl;
  const PlayerView({
    Key? key,
    required this.audioControl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Center(
          child: Obx(
            () => CachedNetworkImage(
              key: ValueKey(
                  "track_cover_${audioControl.currentTrack.value!.id}"),
              url: audioControl.currentTrack.value!.getCoverUri(),
              width: 200,
              height: 200,
              cacheTag: "track_cover_${audioControl.currentTrack.value!.id}",
            ),
          ),
        ),
        const SizedBox(height: 30),
        InkWell(
          onTap: () {
            TrackOptionsModal.open(audioControl.currentTrack.value!);
          },
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  audioControl.currentTrack.value?.title ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  audioControl.currentTrack.value?.artistsString ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 300,
          child: Obx(
            () => Slider(
              value: audioControl.position.value.inMicroseconds.toDouble(),
              onChanged: (value) {
                audioControl.seek(Duration(microseconds: value.toInt()));
              },
              min: 0,
              max: audioControl.position.value >
                      audioControl.trackDuration.value
                  ? audioControl.position.value.inMicroseconds.toDouble()
                  : audioControl.trackDuration.value.inMicroseconds.toDouble(),
            ),
          ),
        ),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.loop,
                    color:
                        audioControl.loop.value ? Colors.blue : Colors.black),
                onPressed: () {
                  audioControl.setLoop(!audioControl.loop.value);
                },
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
              IconButton(
                icon: const Icon(Icons.shuffle_rounded),
                onPressed: () {
                  audioControl.shuffle();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
