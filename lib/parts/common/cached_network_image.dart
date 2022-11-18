import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/services/downloader.dart';
import 'package:test/utils/services.dart';

class CachedNetworkImage extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final String? cacheTag;

  const CachedNetworkImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.cacheTag,
  }) : super(key: key);

  @override
  State<CachedNetworkImage> createState() => _CachedNetworkImageState();
}

class _CachedNetworkImageState extends State<CachedNetworkImage> {
  final downloader = Get.find<DownloaderService>();
  bool error = false;
  String? localPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: error
          ? const Center(
              child: Icon(Icons.error),
            )
          : (localPath == null
              ? null
              : Image.file(
                  File(localPath!),
                  width: widget.width,
                  height: widget.height,
                  fit: BoxFit.contain,
                )),
    );
  }

  @override
  void initState() {
    if (widget.url.isNotEmpty) {
      downloader.cacheImage(widget.url, widget.cacheTag).then(
        (value) {
          if (mounted) {
            setState(() {
              localPath = value;
            });
          }
        },
      ).catchError((_e) {
        if (mounted) {
          setState(() {
            error = true;
          });
        }
        if (kDebugMode) {
          print(_e);
        }
      });
    }

    super.initState();
  }
}
