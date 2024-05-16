import 'dart:async';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:mcquenji_firebase/mcquenji_firebase.dart';

/// Guard that checks if the user is authenticated with Firebase Authentication.
///
/// Every module that uses this guard must import the [FirebaseAuthModule].
class FirebaseAuthGuard extends RouteGuard {
  /// Guard that checks if the user is authenticated with Firebase Authentication.
  ///
  /// Every module that uses this guard must import the [FirebaseAuthModule].
  FirebaseAuthGuard({super.redirectTo});

  @override
  FutureOr<bool> canActivate(String path, ParallelRoute route) {
    final auth = Modular.get<FirebaseAuthService>();

    return auth.isAuthenticated;
  }
}
