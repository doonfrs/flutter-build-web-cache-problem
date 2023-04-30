#!/bin/bash

echo incrementing build number
perl -i -pe 's/^(version:\s+\d+\.\d+\.)(\d+)\+(\d+)$/$1.($2+1)."+".($3+1)/e' pubspec.yaml

flutter clean
flutter packages get
flutter build web --release --web-renderer=html --pwa-strategy=none

echo "" > build/web/assets/NOTICES

#replace base href
echo Updating base href
path="/"
sed -i "s|<base href=\"/\">|<base href=\"$path\">|g" build/web/index.html

echo "reading version from pubspec.yaml without + sign"
version=$(grep version: pubspec.yaml | sed 's/version: //g' | sed 's/+//g')

echo "Patching version in js partial urls in main.dart.js"
sed -i 's/\.createScriptURL([[:graph:]]\++[[:space:]]*\+[[:graph:]]/&+"?v='"$version"'"/g' build/web/main.dart.js

echo "Patching main.dart.js path in flutter.js"
sed -i 's|\(${baseUri}main\.dart\.js\)|\1?v='"$version"'|g' build/web/flutter.js

echo "Patching index.html for flutter.js"
sed -i 's/"flutter\.js"/"flutter.js?v='"$version"'"/' build/web/index.html
