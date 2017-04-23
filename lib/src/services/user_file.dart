import 'package:angel_common/angel_common.dart';
import 'package:angel_framework/hooks.dart' as hooks;
import 'package:mongo_dart/mongo_dart.dart';

AngelConfigurer configureServer(Db db) {
  return (Angel app) async {
    app.use('/api/user_files', new MongoService(db.collection('user_files')));
    var service = app.service('api/user_files') as HookedService;
    service
      ..beforeAll(hooks.chainListeners([
        hooks.disable(),
        (HookedServiceEvent e) {
          e.params['broadcast'] = false;
        }
      ]))
      ..afterAll(hooks.remove('directoryPath'));
  };
}
