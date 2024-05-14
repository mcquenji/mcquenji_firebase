export 'domain/domain.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mcquenji_firebase/mcquenji_firebase.dart';
import 'package:mcquenji_firebase/src/firebase_firestore/impl/datasources/datasources.dart';

/// A module that exports the necessary bindings for working with Firestore in a modular way.
///
/// ---
///
/// See also:
///  - [FirebaseFirestoreDataSource] for raw access to Firestore operations.
///  - [TypedFirebaseFirestoreDataSource] for a typed interface to Firestore operations.
class FirebaseFirestoreModule extends Module {
  /// A module that exports the necessary bindings for working with Firestore in a modular way.
  ///
  /// ---
  ///
  /// See also:
  ///  - [FirebaseFirestoreDataSource] for raw access to Firestore operations.
  ///  - [TypedFirebaseFirestoreDataSource] for a typed interface to Firestore operations.
  FirebaseFirestoreModule();

  @override
  void exportedBinds(Injector i) {
    i.addLazySingleton(() => FirebaseFirestore.instance);
    i.addLazySingleton<FirebaseFirestoreDataSource>(
      StdFirebaseFirestoreDataSource.new,
    );
  }
}
