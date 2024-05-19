# flutter-build-web-cache-problem
Please give this repo a star ⭐ if you found the script useful.

I've tried all solutions to avoid caching after a new web-futter build, especially using deferred components, which lead to many main.dart.partxyz.js.

Flutter does not add the version number to those URLs.

I ended up with the following script; I hope it helps someone.

```bash
#!/bin/bash

dos2unix pubspec.yaml
echo "incrementing build version..."
perl -i -pe 's/^(version:\s+\d+\.\d+\.)(\d+)\+(\d+)$/$1.($2+1)."+".($3+1)/e' pubspec.yaml

flutter clean
flutter packages get
flutter build web --release --web-renderer=canvaskit --pwa-strategy=none #--no-tree-shake-icons #--source-maps


#replace base href
echo Updating base href
baseHref="/"

sed -i "s|<base href=\"/\">|<base href=\"$baseHref\">|g" build/web/index.html

echo "reading version from pubspec.yaml without + sign"
version=$(grep version: pubspec.yaml | sed 's/version: //g' | sed 's/+//g')

echo "Patching version in js partial urls in main.dart.js"
sed -i "s/\`\${w}\${s}\`/\`\${w}\${s}?v=$version\`/g" build/web/flutter.js
sed -i "s/\`\${w}\${s}\`/\`\${w}\${s}?v=$version\`/g" build/web/flutter_bootstrap.js
sed -i "s/\`\${w}\${s}\`/\`\${w}\${s}?v=$version\`/g" build/web/index.html


echo "Patching assets loader with v=$version in main.dart.js"
sed -i "s/self\.window\.fetch(a),/self.window.fetch(a + '?v=$version'),/g" build/web/main.dart.js
echo "Adding v= to manifest.json"
sed -i 's/"manifest.json"/"manifest.json?v='"$version"'"/' build/web/index.html

```
