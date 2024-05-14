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
    final doc = await db.doc(path).get();

    if (!doc.exists) return;

    return doc.reference.delete();
  }

  @override
  void dispose() {
    for (var stream in _watchedDocs.values) {
      stream.close();
    }
    _watchedDocs.clear();

    for (var stream in _watchedCollections.values) {
      stream.close();
    }
    _watchedCollections.clear();
  }

  @override
  Future<Map<String, dynamic>?> read(String path) async {
    var ref = await db.doc(path).get();

    return ref.data();
  }

  @override
  Future<Map<String, dynamic>> readAll(String path) async {
    Map<String, Map<String, dynamic>> data = {};

    var ref = await db.collection(path).get();

    for (var doc in ref.docs) {
      data[doc.id] = (doc.data());
    }

    return data;
  }

  @override
  Stream<Either<DocumentDeletedException, Map<String, dynamic>>> watch(
    String path,
  ) {
    if (_watchedDocs.containsKey(path)) {
      return _watchedDocs[path]!.stream.asBroadcastStream();
    }

    final controller = _DocStream();

    db.doc(path).snapshots().listen((event) {
      if (!event.exists) {
        controller.add(Left(DocumentDeletedException(path)));
        controller.close();

        _watchedDocs.remove(path);
        return;
      }

      controller.add(Right(event.data()!));
    });

    _watchedDocs[path] = controller;

    return controller.stream;
  }

  @override
  Future<void> write(Map<String, dynamic> data, String path) async {
    return db.doc(path).set(data);
  }

  @override
  Future<void> update(Map<String, dynamic> data, String path) async {
    return db.doc(path).update(data);
  }

  @override
  Stream<Map<String, Map<String, dynamic>>> watchAll(String path) {
    if (_watchedCollections.containsKey(path)) {
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

          continue;
        }

        data[change.doc.id] = change.doc.data()!;
      }

      controller.add(data);
    });

    _watchedCollections[path] = controller;

    return controller.stream;
  }
}

typedef _DocStream
    = StreamController<Either<DocumentDeletedException, Map<String, dynamic>>>;

typedef _CollectionStream = StreamController<Map<String, Map<String, dynamic>>>;
