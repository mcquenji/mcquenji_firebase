export 'domain/domain.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mcquenji_firebase/src/firebase_auth/impl/impl.dart';

class FirebaseAuthModule extends Module {
  @override
  void exportedBinds(Injector i) {
    i.addInstance(FirebaseAuth.instance);
    i.addLazySingleton(StdFirebaseAuthService.new);
  }
}