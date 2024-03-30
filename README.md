# flutter-build-web-cache-problem
I've tried all solutions to avoid caching after a new web-futter build, especially using deferred components, which lead to many main.dart.partxyz.js.

Flutter does not add the version number to those URLs.

I ended up with the following script; I hope it helps someone.

```bash
echo incrementing build number
perl -i -pe 's/^(version:\s+\d+\.\d+\.)(\d+)\+(\d+)$/$1.($2+1)."+".($3+1)/e' pubspec.yaml

flutter build web --release --web-renderer=canvaskit --pwa-strategy=none


echo "reading version from pubspec.yaml without + sign"
version=$(grep version: pubspec.yaml | sed 's/version: //g' | sed 's/+//g')

echo "Patching version in js partial urls in main.dart.js"
sed -i "s/_createScriptTag(e,r){let t/_createScriptTag(e,r){e+='?v=$version';let t/g" build/web/flutter.js

echo "Patching assets loader with v=$version in main.dart.js"
sed -i "s/self\.window,\"fetch\",\[a\]/self.window,\"fetch\",[a + \"?v=$version\"]/g" build/web/main.dart.js


echo "Patching index.html for flutter.js"
sed -i 's/"flutter\.js"/"flutter.js?v='"$version"'"/' build/web/index.html


echo "Adding v= to manifest.json"
sed -i 's/"manifest.json"/"manifest.json?v='"$version"'"/' build/web/index.html

```
