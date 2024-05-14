import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mcquenji_firebase/mcquenji_firebase.dart';

/// Base implementation of a [FirebaseUserDataSource].
///
/// This class is to be extended by a concrete implementation for your specific user model.
/// The concrete implementation must only implement the [deserialize] and [serialize] methods, as the rest is already implemented.
///
/// ---
///
/// **Example usage:**
///
/// ```dart
/// class MyUserDataSource extends FirebaseUserDataSourceBaseImpl<MyUser> {
///   MyUserDataSource(super.auth, super.db) : super(collectionPath: 'users');
///
///   @override
///   MyUser deserialize(Map<String, dynamic> data) => MyUser.fromJson(data);
///
///   @override
///   Map<String, dynamic> serialize(MyUser user) => user.toJson();
/// }
/// ```
///
/// After implementing the concrete class, add it to your module:
///
/// ```dart
/// class MyModule extends Module {
///   @override
///   void binds(Injector i) {
///     i.addLazySingleton<FirebaseUserDataSource<MyUser>>(MyUserDataSource.new);
///   }
/// }
/// ```
abstract class FirebaseUserDataSourceBaseImpl<T>
    extends FirebaseUserDataSource<T> {
  /// The [FirebaseAuthService] to use.
  final FirebaseAuthService auth;

  /// The [FirebaseFirestoreDataSource] to use.
  final FirebaseFirestoreDataSource db;

  /// The path to the collection to store user data in.
  final String collectionPath;

  /// Base implementation of a [FirebaseUserDataSource].
  ///
  /// This class is to be extended by a concrete implementation for your specific user model.
  /// The concrete implementation must only implement the [deserialize] and [serialize] methods, as the rest is already implemented.
  ///
  /// ---
  ///
  /// **Example usage:**
  ///
  /// ```dart
  /// class MyUserDataSource extends FirebaseUserDataSourceBaseImpl<MyUser> {
  ///   MyUserDataSource(super.auth, super.db) : super(collectionPath: 'users');
  ///
  ///   @override
  ///   MyUser deserialize(Map<String, dynamic> data) => MyUser.fromJson(data);
  ///
  ///   @override
  ///   Map<String, dynamic> serialize(MyUser user) => user.toJson();
  /// }
  /// ```
  ///
  /// After implementing the concrete class, add it to your module:
  ///
  /// ```dart
  /// class MyModule extends Module {
  ///   @override
  ///   void binds(Injector i) {
  ///     i.addLazySingleton<FirebaseUserDataSource<MyUser>>(MyUserDataSource.new);
  ///   }
  /// }
  /// ```
  FirebaseUserDataSourceBaseImpl({
    required this.collectionPath,
    required this.auth,
    required this.db,
  });

  /// Deserializes the data from the Firestore database.
  T deserialize(Map<String, dynamic> data);

  /// Serializes the data to be written to the Firestore database.
  Map<String, dynamic> serialize(T user);

  final Map<String, StreamController<T>> _watchedUsers = {};
  StreamController<List<T>>? _allUsersStream;

  @override
  @nonVirtual
  Future<void> delete(String id) {
    return db.delete("$collectionPath/$id");
  }

  @override
  @nonVirtual
  Future<T> read(String id) async {
    var data = await db.read("$collectionPath/$id");

    if (data == null) {
      throw UserNotFoundException(id);
    }

    return deserialize(data);
  }

  @override
  @nonVirtual
  Future<List<T>> readAll() async {
    var data = await db.readAll(collectionPath);

    return data.values.map((e) => deserialize(e)).toList();
  }

  @override
  @nonVirtual
  Stream<T> watch(String id) {
    if (_watchedUsers.containsKey(id)) {
      return _watchedUsers[id]!.stream;
    }

    var controller = StreamController<T>.broadcast();

    db.watch("$collectionPath/$id").listen((event) {
      if (event.isLeft) {
        controller.addError(UserNotFoundException(id));
        controller.close();
        return;
      }

      controller.add(deserialize(event.right));
    });

    _watchedUsers[id] = controller;

    return controller.stream;
  }

  @override
  @nonVirtual
  Stream<List<T>> watchAll() {
    if (_allUsersStream != null) {
      return _allUsersStream!.stream;
    }

    _allUsersStream = StreamController<List<T>>.broadcast();

    db.watchAll(collectionPath).listen((event) {
      _allUsersStream!.add(event.values.map((e) => deserialize(e)).toList());
    });

    return _allUsersStream!.stream;
  }

  @override
  @nonVirtual
  Future<void> write(user, String id) {
    return db.write(serialize(user), "$collectionPath/$id");
  }

  @override
  @nonVirtual
  void dispose() {
    for (var e in _watchedUsers.values) {
      e.close();
    }
    _watchedUsers.clear();

    _allUsersStream?.close();
    _allUsersStream = null;
  }
}
