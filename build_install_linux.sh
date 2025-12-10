#!/bin/bash
set -e

flutter build linux --release

rm -rf ~/flutter_ya_music.bak
mv ~/flutter_ya_music ~/flutter_ya_music.bak

rm -rf ~/flutter_ya_music
cp -r ./build/linux/x64/release/bundle ~/flutter_ya_music
