import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Opens a byte stream from the source, which can be one of:
/// - Stream<List<int>> (identity)
/// - List<int> (memory buffer)
/// - File (will call openRead())
/// - String (will call utf8.encode())
Stream<List<int>> openBytesStream(
    /* String | List<int> | File | Stream<List<int>> */ Object source) {
  if (source is Stream<List<int>>) {
    return source;
  } else if (source is List<int>) {
    return Stream.fromFuture(Future.value(source));
  } else if (source is File) {
    return source.openRead();
  } else if (source is String) {
    return Stream.fromFuture(Future.value(utf8.encode(source)));
  } else {
    throw ArgumentError('Unknown input type: ${source.runtimeType}');
  }
}
