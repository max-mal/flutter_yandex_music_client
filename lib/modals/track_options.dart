import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/controllers/home.dart';
import 'package:test/models/track.dart';
import 'package:test/pages/album.dart';
import 'package:test/pages/artist.dart';
import 'package:test/parts/common/cached_network_image.dart';

class TrackOptionsModal extends StatelessWidget {
  final Track track;

  TrackOptionsModal({
    Key? key,
    required this.track,
  }) : super(key: key);

  final homeController = Get.find<HomeController>();

  static open(Track track) async {
    await Get.bottomSheet(TrackOptionsModal(track: track));
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints:
            GetPlatform.isMobile ? null : const BoxConstraints(maxWidth: 320),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
          right: GetPlatform.isMobile ? 0 : 16,
          left: GetPlatform.isMobile ? 0 : 16,
          top: 10,
        ),
        child: Wrap(
          children: [
            const SizedBox(height: 40),
            ListTile(
              leading: CachedNetworkImage(
                url: track.getCoverUri(),
                width: 40,
                height: 40,
                cacheTag: "track_cover_${track.id}",
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${track.artistsString} - ${track.albumsString}",
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                homeController.likeTracks([track], value: !track.isLikedRx());
                Get.back();
              },
              child: ListTile(
                leading: Icon(
                  track.isLikedRx() ? Icons.favorite : Icons.favorite_border,
                  color: track.isLikedRx() ? Colors.red : Colors.black,
                ),
                title: const Text('Нравится'),
              ),
            ),
            InkWell(
              onTap: () {
                homeController.dislikeTracks(
                  [track],
                  value: !track.isDislikedRx(),
                );
                Get.back();
              },
              child: ListTile(
                leading: Icon(Icons.cancel_outlined,
                    color: track.isDislikedRx() ? Colors.red : Colors.black),
                title: const Text('Не нравится'),
              ),
            ),
            InkWell(
              onTap: () {
                homeController.downloadTracks([
                  track,
                ]);
                Get.back();
              },
              child: ListTile(
                leading: Icon(
                  track.isDownloadedRx() ? Icons.download_done : Icons.download,
                  color: track.isDownloadedRx() ? Colors.green : Colors.black,
                ),
                title: const Text('Скачать'),
              ),
            ),
            InkWell(
              onTap: () {
                Get.back();
                AlbumPage.open(track.albumIds.first);
              },
              child: const ListTile(
                leading: Icon(
                  Icons.album,
                ),
                title: Text('Перейти к альбому'),
              ),
            ),
            InkWell(
              onTap: () {
                Get.back();
                ArtistPage.open(track.artistIds.first);
              },
              child: const ListTile(
                leading: Icon(
                  Icons.person,
                ),
                title: Text('Перейти к исполнителю'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
