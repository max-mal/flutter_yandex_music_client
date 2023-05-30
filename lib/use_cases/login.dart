import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:test/models/user.dart';
import 'package:test/repos/user.dart';
import 'package:test/services/api.dart';
import 'package:test/services/downloader.dart';
import 'package:test/services/hive.dart';
import 'package:test/services/oauth.dart';
import 'package:test/services/prefs.dart';

class LoginUseCase {
  final oauth = Get.find<OAuthService>();
  final api = Get.find<ApiService>();
  final prefs = Get.find<PrefsService>();
  final hive = Get.find<HiveService>();
  final downloader = Get.find<DownloaderService>();

  loadAccessToken() {
    api.token = prefs.getAccessToken();
    if (kDebugMode) {
      print("Token is ${api.token}");
    }
  }

  bool isAuthorized() {
    return api.token != null;
  }

  requestCode() {
    oauth.openRequestCodeUri();
  }

  Future<User> authorizeByCode(String code) async {
    final token = await oauth.getTokenFromCode(code);
    api.setToken(token);
    prefs.setAccessToken(token);
    return await UserRepository().get(online: true);
  }

  logout() async {
    await prefs.deleteAccessToken();
    api.cleanToken();
    await hive.cleanUp();
    await downloader.clearImagesCache();
    // await downloader.clearTracksCache();
  }
}
