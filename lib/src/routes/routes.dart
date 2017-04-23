library compiler_service.routes;

import 'dart:io';
import 'package:angel_common/angel_common.dart';
import 'package:angel_file_security/angel_file_security.dart';
import 'package:recase/recase.dart';
import 'package:uuid/uuid.dart';
import 'controllers/controllers.dart' as controllers;
import '../models/models.dart';

configureBefore(Angel app) async {
  app.before.add(cors());
}

/// Put your app routes here!
configureRoutes(Angel app) async {
  app.container.singleton(new Uuid());

  app.get('/', redirectGuests);
  app.get('/index.html', redirectGuests);
  app.chain(redirectGuests).get('/compile/:id', redirectGuests);

  app.chain([
    'auth',
    restrictFileUploads(maxFiles: 1, allowedExtensions: ['.dart'])
  ]).post('/upload', handleUpload);
}

redirectGuests(RequestContext req, ResponseContext res) async {
  if (req.properties.containsKey('user'))
    return true;
  else {
    await res.render('guest');
  }
}

handleUpload(
    RequestContext req, User user, Uuid uuid, Directory uploadsDir) async {
  // Handle uploads
  var files = await req.lazyFiles();
  if (files.isEmpty)
    throw new AngelHttpException.badRequest(message: 'No file was uploaded.');

  // Create uniquely-named project directory
  var path = new ReCase(uuid.v4()).snakeCase;
  var projectDir = new Directory.fromUri(uploadsDir.uri.resolve(path));
  await projectDir.create(recursive: true);

  // Create pubspec.yaml
  var pubspec = new File.fromUri(projectDir.uri.resolve('pubspec.yaml'));
  await pubspec.create();
  var sink = pubspec.openWrite()..write('name: compiler_service_$path');
  await sink.close();

  // Create web/main.dart
  var mainFile = new File.fromUri(projectDir.uri.resolve('web/main.dart'));
  await mainFile.create(recursive: true);
  sink = mainFile.openWrite()..add(files.first.data);
  await sink.close();

  var userFileService = req.app.service('api/user_files');

  // Create UserFile and return it
  return await userFileService
      .create({'userId': user.id, 'directoryPath': projectDir.absolute.path});
}

void buildProject(
    UserFile result, Directory projectDir, Service userFileService) {
  Process
      .run('pub', ['build'], workingDirectory: projectDir.absolute.path)
      .then((result) async {
    if (result.exitCode != 0) {
      // TODO: Handle failure
    } else {
      // TODO: Handle success
    }
  });
}

configureAfter(Angel app) async {
  // Uncomment this to proxy over pub serve while in development:
  await app.configure(new PubServeLayer());

  // Static server at /web or /build/web, depending on if in production
  //
  // In production, `Cache-Control` headers will also be enabled.
  var vDir = new CachingVirtualDirectory();
  await app.configure(vDir);

  var uploadsDir = new Directory.fromUri(vDir.source.uri.resolve('uploads'));
  if (!await uploadsDir.exists()) await uploadsDir.create(recursive: true);
  app.inject('uploadsDir', uploadsDir);

  // Set our application up to handle different errors.
  var errors = new ErrorHandler(handlers: {
    404: (req, res) async =>
        res.render('error', {'message': 'No file exists at ${req.path}.'}),
    500: (req, res) async => res.render('error', {'message': req.error.message})
  });

  errors.fatalErrorHandler = (AngelFatalError e) async {
    var req = await RequestContext.from(e.request, app);
    var res = new ResponseContext(e.request.response, app);
    res.render('error', {'message': 'Internal Server Error: ${e.error}'});
    await app.sendResponse(e.request, req, res);
  };

  // Throw a 404 if no route matched the request
  app.after.add(errors.throwError());

  // Handle errors when they occur, based on outgoing status code.
  // By default, requests will go through the 500 handler, unless
  // they have an outgoing 200, or their status code has a handler
  // registered.
  app.after.add(errors.middleware());

  // Pass AngelHttpExceptions through handler as well
  await app.configure(errors);

  // Compress via GZIP
  // Ideally you'll run this on a `multiserver` instance, but if not,
  // feel free to knock yourself out!
  //
  app.responseFinalizers.add(gzip());
}

configureServer(Angel app) async {
  await configureBefore(app);
  await configureRoutes(app);
  await app.configure(controllers.configureServer);
  await configureAfter(app);
}
