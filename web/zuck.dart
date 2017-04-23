@JS()
library zuck;

import 'package:js/js.dart';

@JS()
class Zuck {
  external factory Zuck(String timeline, ZuckOptions options);
  external void update(StoryInfo story);
  external void remove(StoryInfo story);
  external void addItem(String storyId, StoryItem item);
  external void removeItem(String storyId, StoryItem item);
}

@JS()
@anonymous
class ZuckOptions {
  external String get id;
  external set id(String v);
  external String get skin;
  external set skin(String v);
  external bool get avatars;
  external set avatars(bool v);
  external bool get list;
  external set list(bool v);
  external bool get openEffect;
  external set openEffect(bool v);
  external bool get cubeEffect;
  external set cubeEffect(bool v);
  external bool get autoFullScreen;
  external set autoFullScreen(bool v);
  external bool get backButton;
  external set backButton(bool v);
  external bool get backNative;
  external set backNative(bool v);

  external factory ZuckOptions(
      {String id,
      String skin,
      bool avatars: true,
      bool list: false,
      bool openEffect: true,
      bool cubeEffect: false,
      bool autoFullScreen: false,
      bool backButton: true,
      bool backNative: false});
}

@JS()
@anonymous
class StoryInfo {
  external factory StoryInfo(
      {String id,
      String photo,
      String name,
      String link,
      String lastUpdated,
      bool seen,
      List<StoryItem> items});
}

@JS()
@anonymous
class StoryItem {
  external factory StoryItem(
      {String id,
      String type,
      int length,
      String src,
      String preview,
      String link,
      String linkText,
      time,
      bool seen});
}
