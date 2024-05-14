import 'package:mcquenji_core/mcquenji_core.dart';

/// Base class every datasource managing user data must extend.
abstract class FirebaseUserDataSource<T> extends Datasource {
  @override
  String get name => 'Firebase.Auth.Users';

  /// Saves the given [user] to the datasource with the given [id].
  ///
  /// If a document with the given [id] already exists, it will be updated. Otherwise, a new document will be created.
  Future<void> write(T user, String id);

  /// Reads the user data from the datasource with the given [id].
  Future<T> read(String id);

  /// Deletes the user data from the datasource with the given [id].
  Future<void> delete(String id);

  /// Returns a stream of user data from the datasource with the given [id].
  ///
  /// The stream will emit the current user data and any subsequent changes to the user data.
  Stream<T> watch(String id);

  /// Returns all user's stored in the datasource.
  Future<List<T>> readAll();

  /// Returns a stream of all user's stored in the datasource.
  ///
  /// The stream will emit the current list of user's and any subsequent changes to the list of user's.
  ///
  /// ---
  ///
  /// **CAUTION:**
  /// Depending on how many users you have, this may deplete your quota.
  /// Use with caution.
  Stream<List<T>> watchAll();
}
