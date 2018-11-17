import 'dart:typed_data';

import 'package:buffer/buffer.dart';

import 'package:test/test.dart';

void main() {
  group('Write test', () {
    test('simple write', () async {
      final writer = new ByteDataWriter(bufferLength: 12);
      writer.writeUint64(13);
      writer.writeUint64(13, Endian.little);
      final bytes = writer.toBytes();
      expect(bytes, hasLength(16));
      expect(
          bytes.map((b) => (b & 0xff).toRadixString(16).padLeft(2, '0')).join(),
          '000000000000000d0d00000000000000');

      final reader = new ByteDataReader();
      for (int i = 0; i < bytes.length; i++) {
        reader.add(bytes.sublist(i, i + 1));
      }
      expect(reader.remainingLength, 16);
      expect(reader.readUint64(), 13);
      expect(reader.remainingLength, 8);
      expect(reader.readUint64(Endian.little), 13);
      expect(reader.remainingLength, 0);

      for (int i = 0; i < bytes.length; i += 2) {
        reader.add(bytes.sublist(i, i + 2));
      }
      expect(reader.read(9), [0, 0, 0, 0, 0, 0, 0, 13, 13]);
      expect(reader.remainingLength, 7);
    });
  });
}
