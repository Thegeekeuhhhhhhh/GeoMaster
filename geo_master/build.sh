export PATH=$PWD/f/bin:$PATH
./f/bin/flutter pub get
./f/bin/flutter create . --platforms web
./f/bin/flutter build web --release --dart-define=PROJECT_URL=$PROJECT_URL --dart-define=PUBLISHABLE_KEY=$PUBLISHABLE_KEY