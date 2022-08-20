#!/bin/bash

flutter build macos --release
rm -rf /Applications/YaMusic.app
cp -r build/macos/Build/Products/Release/YaMusic.app /Applications/