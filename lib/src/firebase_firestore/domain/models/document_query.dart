import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_query.freezed.dart';

/// A query to filter documents in Firestore.
@freezed
class DocumentQuery with _$DocumentQuery {
  const DocumentQuery._();

  /// A query to filter documents in Firestore.
  factory DocumentQuery(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,

    /// Subqueries to apply to the results of this query (applied in the order they are added)
    ///
    /// Subqueries must not have subqueries themselves.
    @Default([]) List<DocumentQuery> subqueries,
  }) = _DocumentQuery;

  /// Queries the results of this query.
  DocumentQuery where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    final query = DocumentQuery(
      field,
      isEqualTo: isEqualTo,
      isNotEqualTo: isNotEqualTo,
      isLessThan: isLessThan,
      isLessThanOrEqualTo: isLessThanOrEqualTo,
      isGreaterThan: isGreaterThan,
      isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
      arrayContains: arrayContains,
      arrayContainsAny: arrayContainsAny,
      whereIn: whereIn,
      whereNotIn: whereNotIn,
      isNull: isNull,
    );

    return DocumentQuery(
      field,
      subqueries: [...subqueries, query],
    );
  }
}
