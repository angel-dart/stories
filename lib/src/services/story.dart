import 'package:angel_common/angel_common.dart';
import 'package:angel_framework/hooks.dart' as hooks;
import 'package:angel_security/hooks.dart' as auth;
import 'package:mongo_dart/mongo_dart.dart';

AngelConfigurer configureServer(Db db) {
  return (Angel app) async {
    app.use('/api/stories', new MongoService(db.collection('stories')));
    var service = app.service('api/stories') as HookedService;

    service
      ..before([
        HookedServiceEvent.CREATED,
        HookedServiceEvent.MODIFIED,
        HookedServiceEvent.UPDATED,
        HookedServiceEvent.REMOVED
      ], hooks.disable())
      ..beforeCreated.listen(hooks.addCreatedAt())
      ..beforeModify(hooks.addUpdatedAt());
  };
}
