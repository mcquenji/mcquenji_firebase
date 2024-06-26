import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mcquenji_core/mcquenji_core.dart';
import 'package:mcquenji_firebase/mcquenji_firebase.dart';
import 'package:mcquenji_firebase/src/firebase_firestore/firebase_firestore.dart';
import 'package:rxdart/subjects.dart';

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
abstract class TypedFirebaseFirestoreDataSource<T> extends Datasource
    implements IGenericSerializer<T, JSON> {
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

  final Map<String, BehaviorSubject<T>> _documentSubjects = {};
  final Map<(String, DocumentQuery?), BehaviorSubject<Map<String, T>>>
      _collectionSubjects = {};

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
    if (_documentSubjects.containsKey(id)) {
      log('Watch already exists for document with ID: $id in collection: $collectionPath');
      return _documentSubjects[id]!.stream;
    }

    var subject = BehaviorSubject<T>();

    db.watch("$collectionPath/$id").listen((event) {
      if (event.isLeft) {
        log('Document with ID: $id was deleted from collection: $collectionPath');
        subject.addError(DocumentNotFoundException(id));
        subject.close();
        return;
      }

      log('Received update for document with ID: $id in collection: $collectionPath');
      subject.add(deserialize(event.right));
    });

    _documentSubjects[id] = subject;

    log('Watch set up successfully for document with ID: $id in collection: $collectionPath');
    return subject.stream;
  }

  /// Returns all models stored in the Firestore collection.
  ///
  /// The models are returned as a map where the key is the document id and the value is the deserialized data.
  @nonVirtual
  Future<Map<String, T>> readAll({
    String subcollection = "",
    DocumentQuery? where,
  }) async {
    final path = '$collectionPath/$subcollection';

    log('Reading all documents in collection: $path');
    var data = await db.readAll(path);

    log('Successfully read ${data.length} documents from collection: $path');
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
  Stream<Map<String, T>> watchAll({
    String subcollection = "",
    DocumentQuery? where,
  }) {
    final path = '$collectionPath/$subcollection';

    log('Setting up watch on all documents in collection: ${(path, where)}');

    if (_collectionSubjects.containsKey((path, where))) {
      log('Watch already exists for collection: ${(path, where)}');
      return _collectionSubjects[(path, where)]!.stream;
    }

    // Sink is closed in [dispose]
    // ignore: close_sinks
    final subject = BehaviorSubject<Map<String, T>>();

    _collectionSubjects[(path, where)] = subject;

    db.watchAll(path).listen((event) {
      log('Received update for collection: ${(path, where)}');
      subject.add(
        event.map(
          (key, value) => MapEntry(key, deserialize(value)),
        ),
      );
    });

    log('Watch set up successfully for collection: ${(path, where)}');

    return subject.stream;
  }

  @override
  @mustCallSuper
  void dispose() {
    log('Disposing TypedFirebaseFirestoreDataSource for collection: $collectionPath');
    for (var e in _documentSubjects.values) {
      e.close();
    }
    _documentSubjects.clear();
    log('Closed and cleared watched document streams');

    for (var e in _collectionSubjects.values) {
      e.close();
    }
    _collectionSubjects.clear();

    log('Closed and cleared collection streams');
  }

  /// Generates a new document ID.
  String newDocumentId() => db.generateNewDocumentId(collectionPath);

  /// Returns the number of documents in the collection.
  Future<int> count({String subcollection = "", DocumentQuery? where}) =>
      db.count("$collectionPath/$subcollection", where: where);
}
