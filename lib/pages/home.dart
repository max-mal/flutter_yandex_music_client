import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/controllers/home.dart';
import 'package:test/pages/search.dart';
import 'package:test/parts/home/feed_item.dart';
import 'package:test/parts/home/generated_playlist.dart';
import 'package:test/parts/home/secondary_list_item.dart';
import 'package:test/parts/player/player_bar.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Expanded(
                          child: Obx(
                            () => Text(
                              'Привет, ${controller.user.value.firstName}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            SearchPage.open();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            controller.loadHomePage(notification: true);
                          },
                        ),
                        Obx(
                          () => IconButton(
                            icon: Icon(controller.online.value
                                ? Icons.wifi
                                : Icons.wifi_off),
                            onPressed: () {
                              controller.setOnline(!controller.online.value);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: IconButton(
                            onPressed: () => controller.logout(),
                            icon: const Icon(Icons.logout),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.touch,
                          },
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: controller.generatedPlaylists.reversed
                                .map(
                                  (playlist) => HomeGeneratedPlaylist(
                                    playlist: playlist,
                                    onTap: (_playlist) =>
                                        controller.onPlaylistClick(playlist),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.touch,
                        },
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            HomeSecondaryListItem(
                              title: 'Мне нравится',
                              icon:
                                  const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () {
                                controller.onLikedClick();
                              },
                            ),
                            HomeSecondaryListItem(
                              title: 'Загруженное',
                              icon: const Icon(Icons.download_done,
                                  color: Colors.green),
                              onPressed: () {
                                controller.onDownloadedClick();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Obx(
                      () => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: controller.feedEvents
                            // .map(
                            //   (e) => Text(e.toString()),
                            // )
                            .map(
                              (e) => HomeFeedItem(
                                event: e,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PlayerBar(),
          ],
        ),
      ),
    );
  }
}
