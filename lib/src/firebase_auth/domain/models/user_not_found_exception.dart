/// Exception thrown when the requested user was not found.
class UserNotFoundException implements Exception {
  /// The id of the user that was not found.
  final String userId;

  /// Exception thrown when the requested user was not found.
  UserNotFoundException(this.userId);

  @override
  String toString() => "User with id '$userId' was not found in the database.";
}
