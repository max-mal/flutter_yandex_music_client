import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService extends GetxService {
  late SharedPreferences prefs;

  Future<PrefsService> init() async {
    await initPreferences();
    return this;
  }

  initPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  String? getAccessToken() {
    return prefs.getString("access_token");
  }

  setAccessToken(String token) async {
    await prefs.setString("access_token", token);
  }

  deleteAccessToken() async {
    await prefs.remove("access_token");
  }
}
