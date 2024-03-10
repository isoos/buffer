# Buffer - Dart library for byte buffers and streams.

[![Pub](https://img.shields.io/pub/v/buffer)](https://pub.dev/packages/buffer)

Utility functions and classes to work with byte buffers and streams efficiently,
to read and write binary data formats.

## Examples

Here are some examples of how you can use the `buffer` package:

#### Writing to a ByteDataWriter and reading from a ByteDataReader

This example demonstrates how to write unsigned integers of different sizes to a `ByteDataWriter` and then read them back using a `ByteDataReader`.

```dart
final writer = ByteDataWriter();
writer.writeUint8(255);
writer.writeUint16(65535);
writer.writeUint32(4294967295);

final reader = ByteDataReader();
reader.add(writer.toBytes());
print(reader.readUint8()); // Output: 255
print(reader.readUint16()); // Output: 65535
print(reader.readUint32()); // Output: 4294967295
```
