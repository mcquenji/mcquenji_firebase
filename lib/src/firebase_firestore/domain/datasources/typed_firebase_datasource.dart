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
///   MyModelDataSource({required super.db}) : super(collectionPath: 'my_data');
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
  ///   MyModelDataSource({required super.db}) : super(collectionPath: 'my_data');
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
    required this.db,
  });

  final Map<String, StreamController<T>> _watchedDocuments = {};
  StreamController<Map<String, T>>? _collectionStream;

  /// Saves the given [model] to the Firestore collection with the specified [id].
  ///
  /// The document will be created if it doesn't exist yet.
  /// If a document with the given [id] already exists, it will be overwritten.
  @nonVirtual
  Future<void> write(T model, String id) async {
    log('Writing document with ID: $id to collection: $collectionPath');
    await db.write(serialize(model), "$collectionPath/$id");
    log('Successfully wrote document with ID: $id to collection: $collectionPath');
  }

  /// Reads the model data from the Firestore collection with the specified [id].
  ///
  /// Throws a [DocumentNotFoundException] if the document with the given [id] is not found.
  @nonVirtual
  Future<T> read(String id) async {
    log('Reading document with ID: $id from collection: $collectionPath');
    var data = await db.read("$collectionPath/$id");

    if (data == null) {
      log('Document with ID: $id not found in collection: $collectionPath');
      throw DocumentNotFoundException(id);
    }

    log('Successfully read document with ID: $id from collection: $collectionPath');
    return deserialize(data);
  }

  /// Deletes the model data from the Firestore collection with the specified [id].
  @nonVirtual
  Future<void> delete(String id) async {
    log('Deleting document with ID: $id from collection: $collectionPath');
    await db.delete("$collectionPath/$id");
    log('Successfully deleted document with ID: $id from collection: $collectionPath');
  }

  /// Returns a stream of model data from the Firestore collection with the specified [id].
  ///
  /// The stream will emit the current model data and any subsequent changes to the model data.
  @nonVirtual
  Stream<T> watch(String id) {
    log('Setting up watch on document with ID: $id in collection: $collectionPath');
    if (_watchedDocuments.containsKey(id)) {
      log('Watch already exists for document with ID: $id in collection: $collectionPath');
      return _watchedDocuments[id]!.stream;
    }

    var controller = StreamController<T>.broadcast();

    db.watch("$collectionPath/$id").listen((event) {
      if (event.isLeft) {
        log('Document with ID: $id was deleted from collection: $collectionPath');
        controller.addError(DocumentNotFoundException(id));
        controller.close();
        return;
      }

      log('Received update for document with ID: $id in collection: $collectionPath');
      controller.add(deserialize(event.right));
    });

    _watchedDocuments[id] = controller;

    log('Watch set up successfully for document with ID: $id in collection: $collectionPath');
    return controller.stream;
  }

  /// Returns all models stored in the Firestore collection.
  ///
  /// The models are returned as a map where the key is the document id and the value is the deserialized data.
  @nonVirtual
  Future<Map<String, T>> readAll() async {
    log('Reading all documents in collection: $collectionPath');
    var data = await db.readAll(collectionPath);

    log('Successfully read ${data.length} documents from collection: $collectionPath');
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
    log('Setting up watch on all documents in collection: $collectionPath');
    if (_collectionStream != null) {
      log('Watch already exists for collection: $collectionPath');
      return _collectionStream!.stream;
    }

    _collectionStream = StreamController<Map<String, T>>.broadcast();

    db.watchAll(collectionPath).listen((event) {
      log('Received update for collection: $collectionPath');
      _collectionStream!.add(
        event.map(
          (key, value) => MapEntry(key, deserialize(value)),
        ),
      );
    });

    log('Watch set up successfully for collection: $collectionPath');
    return _collectionStream!.stream;
  }

  @override
  @mustCallSuper
  void dispose() {
    log('Disposing TypedFirebaseFirestoreDataSource for collection: $collectionPath');
    for (var e in _watchedDocuments.values) {
      e.close();
    }
    _watchedDocuments.clear();
    log('Closed and cleared watched document streams');

    _collectionStream?.close();
    _collectionStream = null;
    log('Closed and cleared collection stream');
  }

  /// Deserializes the data from the Firestore database.
  T deserialize(Map<String, dynamic> data);

  /// Serializes the data to be written to the Firestore database.
  Map<String, dynamic> serialize(T data);

  /// Generates a new document ID.
  String newDocumentId() => db.generateNewDocumentId(collectionPath);
}
