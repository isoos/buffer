import 'dart:async';
import 'package:buffer/buffer.dart';
import 'package:charcode/ascii.dart';
import 'package:test/test.dart';

void main() {
  ByteStreamReader reader;

  setUp(() {
    var stream = new Stream<List<int>>.fromIterable([
      [$H, $e, $l, $l, $o, $comma, $space],
      [$w, $o, $r, $l, $d, $exclamation],
    ]);

    reader = new ByteStreamReader();
    stream.pipe(reader);
  });

  test('can read buffer of smaller size', () async {
    expect(await reader.consume(3), [$H, $e, $l]);
  });

  test('can read buffer of exact size', () async {
    expect(await reader.consume(7), [$H, $e, $l, $l, $o, $comma, $space]);
  });

  test('can read buffer of greater size', () async {
    expect(await reader.consume(10),
        [$H, $e, $l, $l, $o, $comma, $space, $w, $o, $r]);
  });

  test('fails on reads of too large a size', () async {
    expect(() => reader.consume(1000), throwsStateError);
  });

  test('subsequent reads', () async {
    expect(await reader.consume(3), [$H, $e, $l]);
    expect(await reader.consume(3), [$l, $o, $comma]);
  });

  group('enqueued reads', () {
    Stream<List<int>> data;

    setUp(() {
      data = new Stream<List<int>>.fromIterable([
        [$f, $o, $o],
        [$b, $a],
        [$r],
      ]);
    });

    test('data added after listening', () async {
      var reader = new ByteStreamReader();
      var f = reader.consume(5);
      data.pipe(reader);
      expect(f, completion([$f, $o, $o, $b, $a]));
    });

    test('subsequent reads', () async {
      var reader = new ByteStreamReader();
      var f = reader.consume(2);
      var g = reader.consume(4);
      print('g should be ${[$o, $o, $b, $a]}');
      data.pipe(reader);
      expect(f, completion([$f, $o]));
      expect(g, completion([$o, $b, $a, $r]));
    });
  });
}
