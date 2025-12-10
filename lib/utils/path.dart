import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class PathUtil {
	static Future<Directory> getApplicationDirectory() async {
    Directory appDocDir;
    
    if (GetPlatform.isAndroid) {
      appDocDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    } else {
      appDocDir = await getApplicationDocumentsDirectory();
    }
		    
    appDocDir = Directory(appDocDir.path + '/flutter_yandex_music');
    await PathUtil.createDirectoryIfNotExists(appDocDir.path);

    return appDocDir;
	}

	static Future<void> createDirectoryIfNotExists(String path) async {
    if (!await Directory(path).exists()) {
      await Directory(path).create(recursive: true);
    }
  }
}