export 'domain/domain.dart';
export 'guards/guards.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mcquenji_firebase/mcquenji_firebase.dart';
import 'package:mcquenji_firebase/src/firebase_auth/impl/impl.dart';

/// Module for working with Firebase Authentication in a modular way.
///
/// ---
///
/// See also:
///   - [FirebaseAuthGuard] to protect routes with Firebase Authentication.
class FirebaseAuthModule extends Module {
  /// Module for working with Firebase Authentication in a modular way.
  ///
  /// ---
  ///
  /// See also:
  ///   - [FirebaseAuthGuard] to protect routes with Firebase Authentication.
  FirebaseAuthModule();

  @override
  void exportedBinds(Injector i) {
    i.addInstance(FirebaseAuth.instance);
    i.addLazySingleton<FirebaseAuthService>(StdFirebaseAuthService.new);
  }
}
