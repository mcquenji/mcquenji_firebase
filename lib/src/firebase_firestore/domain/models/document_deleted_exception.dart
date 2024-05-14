/// Exception thrown when a document was deleted while being watched.
class DocumentDeletedException implements Exception {
  /// The path of the document that was deleted.
  final String path;

  /// Exception thrown when a document was deleted while being watched.
  DocumentDeletedException(this.path);

  @override
  String toString() => "Document at path '$path' was deleted.";
}
