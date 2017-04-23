import 'package:angel_common/angel_common.dart';
import 'package:angel_framework/hooks.dart' as hooks;
import 'package:mongo_dart/mongo_dart.dart';

configureServer(Db db) {
  return (Angel app) async {
    app.use('/api/users', new MongoService(db.collection('users')));

    HookedService service = app.service('api/users');

    // Prevent clients from doing anything to the `users` service,
    // apart from reading a single user's data.
    service.before([
      HookedServiceEvent.INDEXED,
      HookedServiceEvent.CREATED,
      HookedServiceEvent.MODIFIED,
      HookedServiceEvent.UPDATED,
      HookedServiceEvent.REMOVED
    ], hooks.disable());
  };
}
