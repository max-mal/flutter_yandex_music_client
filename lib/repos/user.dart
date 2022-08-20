import 'package:get/get.dart';
import 'package:test/models/user.dart';
import 'package:test/services/api.dart';
import 'package:test/services/hive.dart';

class UserRepository {
  final api = Get.find<ApiService>();
  final hive = Get.find<HiveService>();

  Future<User> get({bool online = false}) async {
    if (!online) {
      return hive.userBox.get('me', defaultValue: User())!;
    }

    final user = await api.account();
    await put(user);
    return user;
  }

  put(User user) async {
    await hive.userBox.put('me', user);
  }
}
