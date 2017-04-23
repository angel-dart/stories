import 'dart:async';
import 'dart:html';
import 'package:angel_websocket/browser.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:story/src/models/models.dart';
import 'zuck.dart';

final Map<String, User> users = {};
final List<String> storyIds = [];

final DateFormat _fmt = new DateFormat.yMd();
final Uri _uri = Uri.parse(window.location.origin);

final String baseUrl = _uri.host;
final WebSockets wsClient = new WebSockets('ws://${window.location.host}/ws');

final Zuck stories = new Zuck('stories', new ZuckOptions(skin: 'snapssenger'));

final DivElement $storyContainer = querySelector('#story-container'),
    $guestArea = querySelector('#guest-area'),
    $uploadArea = querySelector('#upload-area'),
    $uploadProgress = querySelector('#upload-progress'),
    $uploadProgressBar = querySelector('#upload-progress-bar');
final ButtonElement $signin = querySelector('#sign-in'),
    $uploadBtn = querySelector('#upload-btn');
final FormElement $uploadForm = querySelector('#upload-form');
final FileUploadInputElement $uploadFile = querySelector('#upload-file');

main() async {
  await wsClient.connect();

  wsClient.onError.listen((e) {
    window.alert('Error: $e');
    window.console.error(e.message);
    e.errors.forEach(window.console.error);
  });

  WebSocketsService userService = wsClient.service('api/users'),
      storyService = wsClient.service('api/stories');
  configureUsers(userService);
  configureStories(storyService, userService);

  $signin.onClick.listen((e) {
    e.preventDefault();
    wsClient.authenticateViaPopup('/auth/google').listen((token) {
      wsClient.authToken = token;
      $guestArea.style.display = 'none';
      $uploadArea.style.display = 'initial';
      $uploadForm.onSubmit.listen(handleUpload);
    });
  });
}

void handleUpload(Event event) {
  event.preventDefault();

  if ($uploadFile.files.isEmpty) {
    window.alert('No file provided.');
    return;
  }

  $uploadProgress.style.display = 'initial';
  $uploadBtn..style.display = 'none';

  var xhr = new HttpRequest();
  xhr.open('POST', '/api/upload');
  xhr
    ..responseType = 'json'
    ..setRequestHeader('Accept', 'application/json')
    ..setRequestHeader('Authorization', 'Bearer ${wsClient.authToken}')
    ..onProgress.listen((e) {
      int percent = (e.loaded * 100.0 / e.total).round();
      $uploadProgress.dataset['percent'] = percent.toString();
      $uploadProgressBar.style.width = '$percent%';
    })
    ..onLoadEnd.listen((_) {
      try {
        var story = Story.parse(xhr.response);
        if (story.id?.isNotEmpty != true) throw new Exception();
        window.console.info('Created story #${story.id}: ${story.toJson()}');
        window.alert('Uploaded your story!');
      } catch (e) {
        window.alert('Failed to upload your story.');
        window.console.error('Story failed: ${xhr.response}');
      } finally {
        resetForm();
      }
    })
    ..send(new FormData($uploadForm));
}

void resetForm() {
  $uploadBtn.style.display = 'initial';
  $uploadProgress
    ..dataset.remove('percent')
    ..style.display = 'none';
  $uploadProgressBar.style.removeProperty('width');
}

Future<User> loadUser(String userId, WebSocketsService userService) {
  var c = new Completer<User>();

  if (users.containsKey(userId)) {
    c.complete(users[userId]);
  } else {
    StreamSubscription<WebSocketEvent> sub;
    sub = userService.onRead.listen(
        (e) {
          try {
            var user = User.parse(e.data);
            sub.cancel();

            // Add story
            stories.update(userToStory(user));
            c.complete(user);
          } catch (e, st) {
            c.completeError(e, st);
          }
        },
        cancelOnError: true,
        onError: c.completeError,
        onDone: () {
          c.completeError(new StateError('Failed to load user #$userId.'));
        });
  }

  return c.future;
}

void configureUsers(WebSocketsService userService) {
  userService
    ..onIndexed.listen((e) async {
      try {
        var loaded = e.data as List;

        for (var data in loaded) {
          try {
            addUser(User.parse(data));
          } catch (e) {
            // Fail silently
          }
        }
      } catch (e) {
        // Fail silently
      }
    })
    ..onCreated.listen((e) async {
      try {
        addUser(User.parse(e.data));
      } catch (e) {
        // Fail silently
      }
    })
    ..index();
}

void configureStories(
    WebSocketsService storyService, WebSocketsService userService) {
  storyService
    ..onIndexed.listen((e) async {
      try {
        var loaded = e.data as List;

        for (var data in loaded) {
          try {
            addStory(Story.parse(data), userService);
          } catch (e) {
            // Fail silently
          }
        }
      } catch (e) {
        // Fail silently
      }
    })
    ..onCreated.listen((e) async {
      try {
        await addStory(Story.parse(e.data), userService, true);
      } catch (e) {
        // Fail silently
      }
    })
    ..index();
}

void addUser(User user) {
  if (user.id?.isNotEmpty != true) return;

  users.putIfAbsent(user.id, () {
    stories.update(userToStory(user));
    return user;
  });
}

void addStory(Story story, WebSocketsService userService, [bool alert]) {
  if (story.id?.isNotEmpty != true) return null;

  loadUser(story.userId, userService).then((user) {
    if (alert == true)
      window.alert('${user.name} just uploaded a story! Check it out!');

    if (storyIds.isEmpty) $storyContainer.style.display = 'initial';

    stories.addItem(user.id, storyToItem(story));
    storyIds.add(story.id);
  });
}

StoryInfo userToStory(User user) {
  return new StoryInfo(id: user.id, photo: user.avatar, name: user.name);
}

StoryItem storyToItem(Story story) {
  return new StoryItem(
      id: story.id,
      type: 'photo',
      src: p.join(window.location.origin, './uploads', story.path),
      time: story.createdAt != null ? _fmt.format(story.createdAt) : '');
}
