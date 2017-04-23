import 'package:angel_common/angel_common.dart';
import 'package:angel_framework/hooks.dart' as hooks;
import 'package:mongo_dart/mongo_dart.dart';

configureServer(Db db) {
  return (Angel app) async {
    app.use('/api/users', new MongoService(db.collection('users')));

    HookedService service = app.service('api/users');

    service
      ..beforeAll(hooks.disable())
      ..beforeCreated.listen(hooks.addCreatedAt())
      ..beforeModify(hooks.addUpdatedAt());
  };
}
