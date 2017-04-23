library compiler_service.services;

import 'package:angel_common/angel_common.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'compilation_request.dart' as compilation_request;
import 'user_file.dart' as user_file;
import 'user.dart' as user;

configureServer(Angel app) async {
  Db db = app.container.make(Db);
  await app.configure(compilation_request.configureServer(db));
  await app.configure(user.configureServer(db));
  await app.configure(user_file.configureServer(db));
}
