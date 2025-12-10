import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/pages/splash.dart';
import 'package:test/utils/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await ServicesUtil.init();
  runApp(GetMaterialApp(
    title: 'YaMusic',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: false,
    ),
    home: const SplashPage(),
    debugShowCheckedModeBanner: false,
  ));
}
