library compiler_service.config;

import 'dart:convert';
import 'dart:io';
import 'package:angel_common/angel_common.dart';
import 'package:angel_websocket/server.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'plugins/plugins.dart' as plugins;

/// This is a perfect place to include configuration and load plug-ins.
configureServer(Angel app) async {
  await app.configure(loadConfigurationFile());
  var db = new Db(app.mongo_db);
  await db.open();
  app
    ..lazyParseBodies = true
    ..container.singleton(db)
    ..injectSerializer(JSON.encode);

  await app.configure(mustache(new Directory('views')));
  await plugins.configureServer(app);
  app.justBeforeStart
      .add(new AngelWebSocket(register: (Angel app, RequestHandler handler) {
    // Use `register` to hook up WebSockets on a custom route.
    //
    // Here, it is used to open WebSockets ONLY to authenticated users.
    return app.chain('auth').get('/ws', handler);
  }));

  // Uncomment this to enable session synchronization across instances.
  // This will add the overhead of querying a database at the beginning
  // and end of every request. Thus, it should only be activated if necessary.
  //
  // For applications of scale, it is better to steer clear of session use
  // entirely.
  // await app.configure(new MongoSessionSynchronizer(db.collection('sessions')));
}
