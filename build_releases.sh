#!/bin/bash

rm -rf releases
mkdir releases

echo "Building linux release"
fvm exec flutter build linux --release
tar -cf flutter_ya_music-linux.tar -C ./build/linux/x64/release/bundle .
mv flutter_ya_music-linux.tar ./releases

echo "Building android release"
fvm exec flutter build apk --release
cp ./build/app/outputs/flutter-apk/app-release.apk ./releases/flutter_ya_music-android.apk

echo "Done"
