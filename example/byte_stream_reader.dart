import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:buffer/buffer.dart';

/// Parse a packet from some fictional protocol.
Future<Uint8List> getPayloadFrometworkPacket(Socket socket) async {
  // Pipe the stream into the [ByteStreamReader].
  var rdr = ByteStreamReader();
  socket.pipe(rdr);

  // Assume that in this protocol, every packet has a 12-byte header:
  // * 0: 1 byte indicating protocol version
  // * 1: Additional flags
  // * 2: 2-byte checksum = flags & version
  // * 4: 8 bytes that indicate the length of the rest of the packet (payload).

  // Let's read our data!.
  var protocolVersion = await rdr.readUint8();
  var flags = await rdr.readUint8();
  var checksum = await rdr.readUint16();
}

