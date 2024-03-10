import 'package:buffer/buffer.dart';

void main() {
  /// Writing to a ByteDataWriter and reading from a ByteDataReader
  {
    final writer = ByteDataWriter();
    writer.writeUint8(255);
    writer.writeUint16(65535);
    writer.writeUint32(4294967295);

    final reader = ByteDataReader();
    reader.add(writer.toBytes());
    print(reader.readUint8()); // Output: 255
    print(reader.readUint16()); // Output: 65535
    print(reader.readUint32()); // Output: 4294967295
  }

  /// Writing and reading strings
  {
    final writer = ByteDataWriter();
    var string = 'Hello World!';
    writeUtf8String(writer, string);

    final reader = ByteDataReader();
    reader.add(writer.toBytes());
    print(readUtf8String(reader, string.length)); // Output: Hello World!
  }

  /// Reading until a terminating byte
  {
    final reader = ByteDataReader();
    reader.add([72, 101, 108, 108, 111, 0, 87, 111, 114, 108, 100, 0]);
    print(
        reader.readUntilTerminatingByte(0)); // Output: [72, 101, 108, 108, 111]
    print(
        reader.readUntilTerminatingByte(0)); // Output: [87, 111, 114, 108, 100]
  }
}

void writeUtf8String(ByteDataWriter buffer, String string) {
  for (var i = 0; i < string.length; i++) {
    buffer.writeUint8(string.codeUnitAt(i));
  }
}

String readUtf8String(ByteDataReader buffer, int length) {
  final string = StringBuffer();
  for (var i = 0; i < length; i++) {
    string.writeCharCode(buffer.readUint8());
  }
  return string.toString();
}
