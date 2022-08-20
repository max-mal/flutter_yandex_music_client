import 'package:flutter/material.dart';
import 'package:test/parts/common/cached_network_image.dart';

class SearchItem extends StatelessWidget {
  final String title;
  final String coverUri;
  final String? cacheTag;
  final Function onTap;

  const SearchItem({
    Key? key,
    required this.title,
    required this.coverUri,
    required this.onTap,
    this.cacheTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: ListTile(
        leading: CachedNetworkImage(
          url: coverUri,
          cacheTag: cacheTag,
          height: 40,
          width: 40,
        ),
        title: Text(title),
      ),
    );
  }
}
