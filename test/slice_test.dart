import 'dart:async';

import 'package:buffer/buffer.dart';

import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    test('empty', () async {
      final stream = sliceStream(Stream.empty(), 10);
      expect(await stream.toList(), []);
    });

    test('smaller', () async {
      final stream = sliceStream(
          Stream.fromIterable([
            [0, 1, 2],
          ]),
          10);
      expect(await stream.toList(), [
        [0, 1, 2],
      ]);
    });

    test('big bang', () async {
      var num = 0;
      final stream = sliceStream(
          Stream.fromIterable(List.generate(
            13,
            (i) => List.generate(i + 1, (i) => num++),
          )),
          5);
      expect(await stream.toList(), [
        [0, 1, 2, 3, 4],
        [5, 6, 7, 8, 9],
        [10, 11, 12, 13, 14],
        [15, 16, 17, 18, 19],
        [20, 21, 22, 23, 24],
        [25, 26, 27, 28, 29],
        [30, 31, 32, 33, 34],
        [35, 36, 37, 38, 39],
        [40, 41, 42, 43, 44],
        [45, 46, 47, 48, 49],
        [50, 51, 52, 53, 54],
        [55, 56, 57, 58, 59],
        [60, 61, 62, 63, 64],
        [65, 66, 67, 68, 69],
        [70, 71, 72, 73, 74],
        [75, 76, 77, 78, 79],
        [80, 81, 82, 83, 84],
        [85, 86, 87, 88, 89],
        [90],
      ]);
      expect(num, 91);
    });
  });
}
