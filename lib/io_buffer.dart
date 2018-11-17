import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Opens a byte stream from the source, which can be one of:
/// - Stream<List<int>> (identity)
/// - List<int> (memory buffer)
/// - File (will call openRead())
/// - String (will call utf8.encode())
Stream<List<int>> openBytesStream(
    /* String | List<int> | File | Stream<List<int>> */ source) {
  if (source == null) {
    return null;
  } else if (source is Stream<List<int>>) {
    return source;
  } else if (source is List<int>) {
    return new Stream.fromFuture(new Future.value(source));
  } else if (source is File) {
    return source.openRead();
  } else if (source is String) {
    return new Stream.fromFuture(new Future.value(utf8.encode(source)));
  } else {
    throw new ArgumentError('Unknown input type: ${source.runtimeType}');
  }
}
