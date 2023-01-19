import 'package:get/get.dart';
import 'package:test/services/api.dart';
import 'package:test/services/audio_control.dart';
import 'package:test/services/downloader.dart';
import 'package:test/services/hive.dart';
import 'package:test/services/oauth.dart';
import 'package:test/services/prefs.dart';

class ServicesUtil {
  static init() async {
    Get.put(await PrefsService().init(), permanent: true);
    Get.put(await ApiService().init(), permanent: true);
    Get.put(await OAuthService().init(), permanent: true);
    Get.put(await HiveService().init(), permanent: true);
    Get.put(await DownloaderService().init(), permanent: true);
    Get.put(await AudioControlService().init(), permanent: true);
  }
}
