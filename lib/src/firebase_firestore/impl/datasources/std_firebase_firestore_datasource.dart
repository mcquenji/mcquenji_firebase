import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:mcquenji_firebase/mcquenji_firebase.dart';

/// Standard implementation of [FirebaseFirestoreDataSource].
class StdFirebaseFirestoreDataSource extends FirebaseFirestoreDataSource {
  /// The database reference to use.
  final FirebaseFirestore db;

  /// Standard implementation of [FirebaseFirestoreDataSource].
  StdFirebaseFirestoreDataSource(this.db);

  final Map<String, _DocStream> _watchedDocs = {};
  final Map<String, _CollectionStream> _watchedCollections = {};

  @override
  Future<void> delete(String path) async {
    log('Attempting to delete document at path: $path');
    final doc = await db.doc(path).get();

    if (!doc.exists) {
      log('Document at path $path does not exist, skipping delete.');
      return;
    }

    await doc.reference.delete();
    log('Successfully deleted document at path: $path');
  }

  @override
  void dispose() {
    log('Disposing StdFirebaseFirestoreDataSource');
    for (var stream in _watchedDocs.values) {
      stream.close();
    }
    _watchedDocs.clear();
    log('Closed and cleared watched document streams');

    for (var stream in _watchedCollections.values) {
      stream.close();
    }
    _watchedCollections.clear();
    log('Closed and cleared watched collection streams');
  }

  @override
  Future<Map<String, dynamic>?> read(String path) async {
    log('Reading document at path: $path');
    var ref = await db.doc(path).get();

    if (ref.data() == null) {
      log('Document at path $path does not exist or has no data.');
    } else {
      log('Successfully read document at path: $path');
    }

    return ref.data();
  }

  @override
  Future<Map<String, dynamic>> readAll(String path) async {
    log('Reading all documents in collection at path: $path');
    Map<String, Map<String, dynamic>> data = {};

    var ref = await db.collection(path).get();

    for (var doc in ref.docs) {
      data[doc.id] = (doc.data());
    }

    log('Successfully read ${data.length} documents from collection at path: $path');
    return data;
  }

  @override
  Stream<Either<DocumentDeletedException, Map<String, dynamic>>> watch(
    String path,
  ) {
    log('Setting up watch on document at path: $path');
    if (_watchedDocs.containsKey(path)) {
      log('Watch already exists for document at path: $path');
      return _watchedDocs[path]!.stream.asBroadcastStream();
    }

    final controller = _DocStream();

    db.doc(path).snapshots().listen((event) {
      if (!event.exists) {
        log('Document at path $path was deleted');
        controller.add(Left(DocumentDeletedException(path)));
        controller.close();

        _watchedDocs.remove(path);
        return;
      }

      log('Received update for document at path: $path');
      controller.add(Right(event.data()!));
    });

    _watchedDocs[path] = controller;
    log('Watch set up successfully for document at path: $path');

    return controller.stream;
  }

  @override
  Future<void> write(Map<String, dynamic> data, String path) async {
    log('Writing document to path: $path with data: $data');
    await db.doc(path).set(data);
    log('Successfully wrote document to path: $path');
  }

  @override
  Future<void> update(Map<String, dynamic> data, String path) async {
    log('Updating document at path: $path with data: $data');
    await db.doc(path).update(data);
    log('Successfully updated document at path: $path');
  }

  @override
  Stream<Map<String, Map<String, dynamic>>> watchAll(String path) {
    log('Setting up watch on collection at path: $path');
    if (_watchedCollections.containsKey(path)) {
      log('Watch already exists for collection at path: $path');
      return _watchedCollections[path]!.stream.asBroadcastStream();
    }

    // The sink is closed when [dispose] is called.
    // ignore: close_sinks
    final controller = _CollectionStream();

    Map<String, Map<String, dynamic>> data = {};

    db.collection(path).snapshots().listen((event) {
      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.removed) {
          data.remove(change.doc.id);
          log('Document with ID ${change.doc.id} was removed from collection at path: $path');
          continue;
        }

        data[change.doc.id] = change.doc.data()!;
        log('Document with ID ${change.doc.id} was updated in collection at path: $path');
      }

      controller.add(data);
      log('Emitted updated data for collection at path: $path');
    });

    _watchedCollections[path] = controller;
    log('Watch set up successfully for collection at path: $path');

    return controller.stream;
  }

  @override
  String generateNewDocumentId(String path) {
    return db.collection(path).doc().id;
  }
}

typedef _DocStream
    = StreamController<Either<DocumentDeletedException, Map<String, dynamic>>>;

typedef _CollectionStream = StreamController<Map<String, Map<String, dynamic>>>;
