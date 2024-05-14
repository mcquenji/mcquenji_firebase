/// Exception thrown when the requested document was not found.
class DocumentNotFoundException implements Exception {
  /// The id of the document that couldn't be found.
  final String id;

  /// Exception thrown when the requested document was not found.
  DocumentNotFoundException(this.id);

  @override
  String toString() => "Document with id '$id' was not found in the database.";
}
