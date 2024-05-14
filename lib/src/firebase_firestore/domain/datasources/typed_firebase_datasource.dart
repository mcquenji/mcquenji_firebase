import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mcquenji_core/mcquenji_core.dart';
import 'package:mcquenji_firebase/mcquenji_firebase.dart';

/// An abstract class to manage a collection in Firestore with a specific data model [T].
/// This class should be extended by a concrete implementation that specifies the [deserialize] and [serialize] methods.
/// The other CRUD operations are already implemented.
///
/// This class handles basic Firestore operations such as reading, writing, deleting,
/// and watching documents and collections.
///
/// ---
///
/// **Example usage:**
///
/// ```dart
/// class MyModelDataSource extends TypedFirebaseFirestoreDataSource<MyModel> {
///   MyModelDataSource(super.auth, super.db) : super(collectionPath: 'my_data');
///
///   @override
///   MyModel deserialize(Map<String, dynamic> data) => MyModel.fromJson(data);
///
///   @override
///   Map<String, dynamic> serialize(MyModel data) => data.toJson();
/// }
/// ```
///
/// After implementing the concrete class, add it to your module:
///
/// ```dart
/// class MyModule extends Module {
///   @override
///   void binds(Injector i) {
///     i.addLazySingleton<TypedFirebaseFirestoreDataSource<MyModel>>(MyModelDataSource.new);
///   }
/// }
/// ```
abstract class TypedFirebaseFirestoreDataSource<T> extends Datasource {
  @override
  String get name => 'Firebase.Firestore.Typed';

  /// The [FirebaseAuthService] to use for authentication.
  final FirebaseAuthService auth;

  /// The [FirebaseFirestoreDataSource] to use for Firestore operations.
  final FirebaseFirestoreDataSource db;

  /// The path to the collection to manage.
  final String collectionPath;

  /// An abstract class to manage a collection in Firestore with a specific data model [T].
  /// This class should be extended by a concrete implementation that specifies the [deserialize] and [serialize] methods.
  /// The other CRUD operations are already implemented.
  ///
  /// This class handles basic Firestore operations such as reading, writing, deleting,
  /// and watching documents and collections.
  ///
  /// ---
  ///
  /// **Example usage:**
  ///
  /// ```dart
  /// class MyModelDataSource extends TypedFirebaseFirestoreDataSource<MyModel> {
  ///   MyModelDataSource(super.auth, super.db) : super(collectionPath: 'my_data');
  ///
  ///   @override
  ///   MyModel deserialize(Map<String, dynamic> data) => MyModel.fromJson(data);
  ///
  ///   @override
  ///   Map<String, dynamic> serialize(MyModel data) => data.toJson();
  /// }
  /// ```
  ///
  /// After implementing the concrete class, add it to your module:
  ///
  /// ```dart
  /// class MyModule extends Module {
  ///   @override
  ///   void binds(Injector i) {
  ///     i.addLazySingleton<TypedFirebaseFirestoreDataSource<MyModel>>(MyModelDataSource.new);
  ///   }
  /// }
  /// ```
  TypedFirebaseFirestoreDataSource({
    required this.collectionPath,
    required this.auth,
    required this.db,
  });

  final Map<String, StreamController<T>> _watchedDocuments = {};
  StreamController<Map<String, T>>? _collectionStream;

  /// Saves the given [model] to the Firestore collection with the specified [id].
  ///
  /// The document will be created if it doesn't exist yet.
  /// If a document with the given [id] already exists, it will be overwritten.
  @nonVirtual
  Future<void> write(T model, String id) {
    return db.write(serialize(model), "$collectionPath/$id");
  }

  /// Reads the model data from the Firestore collection with the specified [id].
  ///
  /// Throws a [DocumentNotFoundException] if the document with the given [id] is not found.
  @nonVirtual
  Future<T> read(String id) async {
    var data = await db.read("$collectionPath/$id");

    if (data == null) {
      throw DocumentNotFoundException(id);
    }

    return deserialize(data);
  }

  /// Deletes the model data from the Firestore collection with the specified [id].
  @nonVirtual
  Future<void> delete(String id) {
    return db.delete("$collectionPath/$id");
  }

  /// Returns a stream of model data from the Firestore collection with the specified [id].
  ///
  /// The stream will emit the current model data and any subsequent changes to the model data.
  @nonVirtual
  Stream<T> watch(String id) {
    if (_watchedDocuments.containsKey(id)) {
      return _watchedDocuments[id]!.stream;
    }

    var controller = StreamController<T>.broadcast();

    db.watch("$collectionPath/$id").listen((event) {
      if (event.isLeft) {
        controller.addError(DocumentNotFoundException(id));
        controller.close();
        return;
      }

      controller.add(deserialize(event.right));
    });

    _watchedDocuments[id] = controller;

    return controller.stream;
  }

  /// Returns all models stored in the Firestore collection.
  ///
  /// The models are returned as a map where the key is the document id and the value is the deserialized data.
  @nonVirtual
  Future<Map<String, T>> readAll() async {
    var data = await db.readAll(collectionPath);

    return data.map((key, value) => MapEntry(key, deserialize(value)));
  }

  /// Returns a stream of all models stored in the Firestore collection.
  ///
  /// The stream will emit the current list of models and any subsequent changes to the list of models.
  ///
  /// ---
  ///
  /// **CAUTION:**
  /// Depending on how many models you have, this may deplete your quota.
  /// Use with caution.
  @nonVirtual
  Stream<Map<String, T>> watchAll() {
    if (_collectionStream != null) {
      return _collectionStream!.stream;
    }

    _collectionStream = StreamController<Map<String, T>>.broadcast();

    db.watchAll(collectionPath).listen((event) {
      _collectionStream!.add(
        event.map(
          (key, value) => MapEntry(key, deserialize(value)),
        ),
      );
    });

    return _collectionStream!.stream;
  }

  @override
  @mustCallSuper
  void dispose() {
    for (var e in _watchedDocuments.values) {
      e.close();
    }
    _watchedDocuments.clear();

    _collectionStream?.close();
    _collectionStream = null;
  }

  /// Deserializes the data from the Firestore database.
  T deserialize(Map<String, dynamic> data);

  /// Serializes the data to be written to the Firestore database.
  Map<String, dynamic> serialize(T data);
}
