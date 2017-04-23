library story.services;

import 'package:angel_common/angel_common.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'story.dart' as story;
import 'user.dart' as user;

configureServer(Angel app) async {
  Db db = app.container.make(Db);
  await app.configure(story.configureServer(db));
  await app.configure(user.configureServer(db));
}
