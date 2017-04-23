import 'package:angel_common/angel_common.dart';
import 'package:angel_framework/hooks.dart' as hooks;
import 'package:angel_security/hooks.dart' as auth;
import 'package:mongo_dart/mongo_dart.dart';

AngelConfigurer configureServer(Db db) {
  return (Angel app) async {
    app.use('/api/compilation_requests',
        new MongoService(db.collection('compilation_requests')));
    var service = app.service('api/compilation_requests') as HookedService;

    service
      ..beforeAll(hooks.disable())
      ..beforeCreated.listen(hooks.chainListeners([
        auth.associateCurrentUser(),
        hooks.addCreatedAt()
      ]))
      ..beforeModify(hooks.addUpdatedAt());
  };
}
