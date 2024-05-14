import 'package:either_dart/either.dart';
import 'package:mcquenji_core/mcquenji_core.dart';
import 'package:mcquenji_firebase/mcquenji_firebase.dart';

/// Base class all data sources working with Firestore must implement.
abstract class FirebaseFirestoreDataSource extends Datasource {
  @override
  String get name => "Firebase.Firestore";

  /// Deletes the document at the given [path].
  ///
  /// ---
  ///
  /// A [path] is a string consiting of the (sub)collection and document id (e.g. "users/123"), whereas the last segment is the document id.
  /// To point to a document in a subcollection, the path should be in the form "collection/document/subcollection/document" or "collection/subcollection/document".
  Future<void> delete(String path);

  /// Reads the document at the given [path].
  ///
  /// If the document does not exist, the future will complete with a null value.
  ///
  /// ---
  ///
  /// A [path] is a string consiting of the (sub)collection and document id (e.g. "users/123"), whereas the last segment is the document id.
  /// To point to a document in a subcollection, the path should be in the form "collection/document/subcollection/document" or "collection/subcollection/document".
  Future<Map<String, dynamic>?> read(String path);

  /// Reads all documents in the collection at the given [path], where the [path] must point to a collection.
  ///
  /// ---
  ///
  /// A [path] is a string consiting of the colloction id and it's (optional) subcollection id (e.g. "users" or "users/123/history").
  Future<Map<String, dynamic>> readAll(String path);

  /// Writes the given [data] to the document at the given [path].
  ///
  /// If the document does not exist, it will be created. If it does exist, it will be overwritten.
  /// ---
  ///
  /// A [path] is a string consiting of the (sub)collection and document id (e.g. "users/123"), whereas the last segment is the document id.
  /// To point to a document in a subcollection, the path should be in the form "collection/document/subcollection/document" or "collection/subcollection/document".
  Future<void> write(Map<String, dynamic> data, String path);

  /// Watches the document at the given [path].
  ///
  /// The stream will emit the document data as a map whenever the document changes.
  /// If the document is deleted, the stream will emit a [DocumentDeletedException] and then close.
  ///
  /// ---
  ///
  /// A [path] is a string consiting of the (sub)collection and document id (e.g. "users/123"), whereas the last segment is the document id.
  /// To point to a document in a subcollection, the path should be in the form "collection/document/subcollection/document" or "collection/subcollection/document".
  Stream<Either<DocumentDeletedException, Map<String, dynamic>>> watch(
    String path,
  );

  /// Updates the document at the given [path] with the given [data].
  ///
  /// The [data] will be merged with the existing document data.
  /// If the document does not exist, this method will throw an exception.
  ///
  /// ---
  ///
  /// A [path] is a string consiting of the (sub)collection and document id (e.g. "users/123"), whereas the last segment is the document id.
  Future<void> update(Map<String, dynamic> data, String path);

  /// Watches all documents in the collection at the given [path].
  ///
  /// The stream will emit the document data as a map whenever a document in the collection changes.
  ///
  /// ---
  ///
  /// A [path] is a string consiting of the colloction id and it's (optional) subcollection id (e.g. "users" or "users/123/history").
  Stream<Map<String, Map<String, dynamic>>> watchAll(String path);
}
