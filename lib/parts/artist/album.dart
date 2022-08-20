import 'package:flutter/material.dart';
import 'package:test/models/album.dart';
import 'package:test/parts/common/cached_network_image.dart';

class ArtistAlbum extends StatelessWidget {
  final Album album;
  final Function(Album) onTap;

  const ArtistAlbum({
    Key? key,
    required this.album,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          onTap(album);
        },
        child: Stack(
          children: [
            const SizedBox(
              width: 150,
              height: 150,
            ),
            CachedNetworkImage(
              key: ValueKey(album.id),
              url: album.getCoverUri(),
              width: 150,
              height: 150,
              cacheTag: "album_${album.id}",
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  album.title,
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
