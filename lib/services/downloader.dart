import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test/models/track.dart';
import 'package:http/http.dart' as http;
import 'package:test/services/hive.dart';
import 'package:crypto/crypto.dart';
import 'package:test/utils/path.dart';

class DownloaderService extends GetxService {
  RxList<Track> tracksQueue = RxList<Track>();
  bool jobRunning = false;

  late final HiveService hive;
  late Directory appDocDir;
  late String downloadsDir;
  late String tracksDir;

  Map<String, bool> cachedPaths = {};


  Future<DownloaderService> init() async {
    hive = Get.find<HiveService>();
    appDocDir = await PathUtil.getApplicationDirectory();
    await PathUtil.createDirectoryIfNotExists(appDocDir.path);

    downloadsDir = appDocDir.path + "/cache";
    await PathUtil.createDirectoryIfNotExists(downloadsDir);

    tracksDir = appDocDir.path + "/tracks";
    await PathUtil.createDirectoryIfNotExists(tracksDir);
    return this;
  }

  Future<String> cacheImage(String url, String? cacheTag) async {
    String hash = cacheTag ?? md5.convert(utf8.encode(url)).toString();

    final localPath = "$downloadsDir/$hash";
    final localFile = File(localPath);
    if (cachedPaths[localPath] != null || await localFile.exists()) {
      cachedPaths[localPath] = true;
      return localPath;
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode >= 400) {
      throw "http statis code is %${response.statusCode}";
    }
    await localFile.writeAsBytes(response.bodyBytes);
    cachedPaths[localPath] = true;
    if (kDebugMode) {
      print("CACHED: $localPath");
    }
    return localPath;
  }

  Future<void> clearImagesCache() async {
    final dir = Directory(downloadsDir);
    await dir.delete(recursive: true);
  }

  Future<void> clearTracksCache() async {
    final dir = Directory(tracksDir);
    await dir.delete(recursive: true);
  }

  process() async {
    jobRunning = true;
    while (tracksQueue.isNotEmpty) {
      Track track = tracksQueue.first;
      try {
        final localPath = await track.createLocalPath();
        File file = File(localPath);
        if (!await file.exists()) {
          final url = await track.getDownloadUrl();
          final response = await http.get(Uri.parse(url));

          await file.writeAsBytes(response.bodyBytes);
        }
        await hive.downloadedTracks.put(track.id, true);
        hive.rxDownloadedTracks.add(track);
        tracksQueue.removeAt(0);
      } catch (e) {
        if (kDebugMode) {
          print("Failed to download track: ${track.title}");
          print(e);
        }

        tracksQueue.removeAt(0);
      }
    }
    jobRunning = false;
  }

  downloadTracks(List<Track> tracks) {
    tracksQueue.addAll(tracks);
    if (!jobRunning) {
      process();
    }
  }
}
