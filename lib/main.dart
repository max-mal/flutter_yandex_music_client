import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/pages/splash.dart';
import 'package:test/utils/services.dart';
import 'package:kplayer/kplayer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Player.boot();
  await ServicesUtil.init();
  runApp(GetMaterialApp(
    title: 'YaMusic',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const SplashPage(),
    debugShowCheckedModeBanner: false,
  ));
}
