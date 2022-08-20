import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/models/playlist.dart';
import 'package:test/parts/common/cached_network_image.dart';

class HomeGeneratedPlaylist extends StatelessWidget {
  final Playlist playlist;
  final Function(Playlist) onTap;

  const HomeGeneratedPlaylist({
    Key? key,
    required this.playlist,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          onTap(playlist);
        },
        child: Stack(
          children: [
            SizedBox(
              width: GetPlatform.isMobile ? 150 : 200,
              height: GetPlatform.isMobile ? 150 : 200,
            ),
            CachedNetworkImage(
              url: playlist.getCoverUri(),
              width: GetPlatform.isMobile ? 150 : 200,
              height: GetPlatform.isMobile ? 150 : 200,
              cacheTag: "home_playlist_${playlist.uid}_${playlist.kind}",
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  playlist.title,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
