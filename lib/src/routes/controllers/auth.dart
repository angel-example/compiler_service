library compiler_service.routes.controllers.auth;

import 'package:angel_auth_google/angel_auth_google.dart';
import 'package:angel_common/angel_common.dart';
import 'package:googleapis/plus/v1.dart';
import '../../models/user.dart';

const GOOGLE_AUTH_SCOPES = const [
  PlusApi.PlusMeScope,
  PlusApi.UserinfoEmailScope,
  PlusApi.UserinfoProfileScope
];

@Expose('/auth')
class AuthController extends Controller {
  AngelAuth auth;

  /// Clients will see the result of `deserializer`, so let's pretend to be a client.
  ///
  /// Our User service is already wired to remove sensitive data from serialized JSON.
  deserializer(String id) async =>
      app.service('api/users').read(id).then(User.parse);

  serializer(User user) async => user.id;

  /// Attempt to log a user in
  GoogleAuthCallback googleAuthVerifier(Service userService) {
    return (_, Person profile) async {
      List<User> users = (await userService.index({
        'query': {'googleId': profile.id}
      }))
          .map(User.parse)
          .toList();

      if (users.isNotEmpty) {
        var user = users.first
          ..avatar = profile.image.url
          ..name = profile.displayName;
        await userService.modify(user.id, user.toJson());
        return user;
      } else {
        var userData = await userService.create({
          'googleId': profile.id,
          'avatar': profile.image.url,
          'name': profile.displayName
        });
        return User.parse(userData);
      }
    };
  }

  @override
  call(Angel app) async {
    // Wire up local authentication, connected to our User service
    auth = new AngelAuth(jwtKey: app.jwt_secret)
      ..serializer = serializer
      ..deserializer = deserializer
      ..strategies.add(new GoogleStrategy(
          callback: googleAuthVerifier(app.service('api/users')),
          config: app.google,
          scopes: GOOGLE_AUTH_SCOPES));

    await super.call(app);
    await app.configure(auth);
  }

  @Expose('/google')
  googleAuth() => auth.authenticate('google');

  @Expose('/google/callback')
  googleAuthCallback() => auth.authenticate(
      'google', new AngelAuthOptions(callback: redirectToIndexWithToken));

  @Expose('/my-token', middleware: const ['auth'])
  echoToken(AngelAuth auth, AuthToken token) =>
      {'token': token.serialize(auth.hmac)};

  redirectToIndexWithToken(req, ResponseContext res, String jwt) async {
    res.redirect('/?token=$jwt');
    return false;
  }
}
