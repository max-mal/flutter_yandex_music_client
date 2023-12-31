import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/controllers/home.dart';
import 'package:test/models/feed_event.dart';
import 'package:test/pages/search.dart';
import 'package:test/parts/home/feed_item.dart';
import 'package:test/parts/home/generated_playlist.dart';
import 'package:test/parts/home/secondary_list_item.dart';
import 'package:test/parts/player/player_bar.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final controller = Get.put(HomeController());

  _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Obx(
              () => GestureDetector(
                onTap: () {
                  controller.copyToken();
                },
                child: Text(
                  'Привет, ${controller.user.value.firstName}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.left,
                ),
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
              icon: Icon(controller.online.value ? Icons.wifi : Icons.wifi_off),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _header(),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: GetPlatform.isMobile ? 166 : 216,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.touch,
                            },
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final playlist = controller.generatedPlaylists[
                                  controller.generatedPlaylists.length -
                                      1 -
                                      index];
                              return HomeGeneratedPlaylist(
                                playlist: playlist,
                                onTap: (_playlist) =>
                                    controller.onPlaylistClick(playlist),
                              );
                            },
                            itemCount: controller.generatedPlaylists.length,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ScrollConfiguration(
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
                                icon: const Icon(Icons.favorite,
                                    color: Colors.red),
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
                              ...controller.userPlaylists
                                  .map(
                                    (playlist) => HomeSecondaryListItem(
                                      title: playlist.title,
                                      icon: const Icon(
                                        Icons.list,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        controller.onPlaylistClick(playlist);
                                      },
                                    ),
                                  )
                                  .toList()
                            ],
                          ),
                        ),
                      ),
                    ),
                    ..._feedSliverList(),
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

  _feedSliverList() {
    List<Widget> slivers = [];
    for (FeedEvent e in controller.feedEvents) {
      slivers.addAll(HomeFeedItem.asSliverList(e));
    }
    return slivers;
  }
}
