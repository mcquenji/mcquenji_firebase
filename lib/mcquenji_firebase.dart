import "package:mcquenji_core/mcquenji_core.dart";
import "package:flutter_modular/flutter_modular.dart";

import 'src/firebase_auth/firebase_auth.dart';
import 'src/firebase_firestore/firebase_firestore.dart';
import 'src/firebase_storage/firebase_storage.dart';

export 'src/firebase_auth/firebase_auth.dart';
export 'src/firebase_firestore/firebase_firestore.dart';
export 'src/firebase_storage/firebase_storage.dart';

/// Provides services for working with Firebase.
///
/// **Note:** This module does not setup your API keys or any other configurations. Refer to the Firebase documentation for more information.
/// ---
///
/// See also:
///   - [FirebaseAuthModule]
///   - [FirebaseFirestoreModule]
///   - [FirebaseStorageModule]
class FirebaseModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];
}
