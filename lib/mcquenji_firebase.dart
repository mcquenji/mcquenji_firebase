/// Provides services for working with Firebase.
///
/// The modules provided in this package are:
///   - [FirebaseAuthModule]
///   - [FirebaseFirestoreModule]
///   - [FirebaseStorageModule]
///
/// ---
///
/// **Note:** This module does not setup your API keys or any other configurations. Refer to the [Firebase documentation](https://firebase.google.com/docs/flutter/setup) for more information.
library mcquenji.modules.firebase;

export 'src/firebase_auth/firebase_auth.dart';
export 'src/firebase_firestore/firebase_firestore.dart';
export 'src/firebase_storage/firebase_storage.dart';

import 'src/firebase_auth/firebase_auth.dart';
import 'src/firebase_firestore/firebase_firestore.dart';
import 'src/firebase_storage/firebase_storage.dart';
