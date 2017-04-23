import 'dart:io';
import 'package:compiler_service/compiler_service.dart';
import 'package:angel_common/angel_common.dart';
import 'package:angel_test/angel_test.dart';
import 'package:test/test.dart';

main() async {
  Angel app;
  TestClient client;

  setUp(() async {
    app = await createServer();
    client = await connectTo(app);
  });

  tearDown(() async {
    await client.close();
    app = null;
  });

  test('index.html via REST', () async {
    var response = await client.get('/api/user_files');
    expect(response, hasStatus(HttpStatus.OK));
  });

  test('Index user_files', () async {
    var user_files = await client.service('api/user_files').index();
    print(user_files);
  });
}