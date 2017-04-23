import 'dart:html';
import 'dart:js';
import 'package:angel_client/browser.dart';
import 'zuck.dart';

main() {
  var stories = new Zuck('stories', new ZuckOptions());
  stories.update(
      'poop',
      new StoryInfo(
          id: 'pee',
          name: 'ok',
          photo: 'https://avatars2.githubusercontent.com/u/9996860?v=3&s=80',
          items: [
            new StoryItem(
                id: 'a',
                type: 'photo',
                src: 'https://angel-dart.github.io/images/logo.png')
          ]));
}
