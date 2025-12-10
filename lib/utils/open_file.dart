import 'dart:io';

import 'package:flutter/foundation.dart';

/// Try to show a file in Linux GUI file manager.
/// Supports Nautilus, Thunar (via DBus), and falls back to xdg-open of the directory.
Future<void> showFile(String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    throw Exception("File not found: $path");
  }

  final absPath = file.absolute.path;

  // -----------------------------
  // 1) Nautilus --select
  // -----------------------------
  if (_hasCmd("nautilus")) {
    if (kDebugMode) {
      print('sharing over nautilus');
    }

    final r = await Process.run("nautilus", ["--select", absPath]);
    if (r.exitCode == 0) return;
  }

  // -----------------------------
  // 2) Thunar via DBus freedesktop API
  // -----------------------------
  if (_hasCmd("dbus-send")) {
    if (kDebugMode) {
      print('sharing over dbus');
    }

    final uri = "file://$absPath";
    final r = await Process.run("dbus-send", [
      "--session",
      "--print-reply",
      "--dest=org.freedesktop.FileManager1",
      "/org/freedesktop/FileManager1",
      "org.freedesktop.FileManager1.ShowItems",
      'array:string:$uri',
      'string:'
    ]);  

    if (r.exitCode == 0) return;
  }

  // -----------------------------
  // 3) Fallback: open directory
  // -----------------------------
  final dir = file.parent.path;
  await Process.run("xdg-open", [dir]);
}

bool _hasCmd(String cmd) {
  return Process.runSync("which", [cmd]).exitCode == 0;
}
