import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import '../buffer.dart';

/// Asynchronously reads data in from a stream of bytes, which may or may not be continuous.
///
/// Use this in cases where the size of incoming content is *unknown* at runtime,
/// i.e. in a network protocol.
class ByteStreamReader extends StreamConsumer<List<int>> {
  final Queue<_ByteStreamReaderAwaiter> _awaiterQueue =
      new DoubleLinkedQueue<_ByteStreamReaderAwaiter>();
  final Queue<Uint8List> _byteQueue = new DoubleLinkedQueue<Uint8List>();

  /// An [Endian] that should be used to read data of length > 1 byte from the stream.
  final Endian endian;

  ByteStreamReader({this.endian: Endian.big});

  /// Consumes a number of bytes from the input stream (see [consume]), then returns
  /// a single [ByteDataReader] that reads the received buffer.
  /// 
  /// You may provide an [endian] value to override the property set on this instance (See [ByteStreamReader].endian).
  Future<ByteDataReader> read(int length, {bool copy: false, Endian endian}) {
    return consume(length).then(
        (buf) => new ByteDataReader(endian: endian ?? this.endian, copy: copy)..add(buf));
  }

  /// Consumes a number of bytes from the input stream (see [consume]), then adds the read data
  /// into a [ByteDataReader].
  Future<void> readInto(ByteDataReader reader, int length, {bool copy}) {
    return consume(length).then((buf) => reader.add(buf, copy: copy));
  }

  /// Returns a [Future] that completes with a buffer of the given size, read
  /// asynchronously from the incoming stream.
  Future<Uint8List> consume(int length) {
    var trace = StackTrace.current;
    // First, check if the top of the byte queue has enough bytes.
    if (_byteQueue.isNotEmpty) {
      var top = _byteQueue.first;

      // If the number of bytes is the *exact* amount, pop it and return.
      if (top.length == length) {
        _byteQueue.removeFirst();
        return new Future<Uint8List>.value(top);
      }

      // Or, if there is an excess of bytes,
      // return it, but only keep the remainder on the stack.
      else if (top.length > length) {
        var remainder =
            new Uint8List.view(top.buffer, top.offsetInBytes + length);
        var out = new Uint8List.view(top.buffer, top.offsetInBytes, length);
        _byteQueue.removeFirst();
        if (remainder.isNotEmpty) _byteQueue.addFirst(remainder);
        return new Future<Uint8List>.value(out);
      }
    }

    // Otherwise, create an awaiter, and try to fill it up.
    var awaiter = new _ByteStreamReaderAwaiter(trace, length);

    // Ideally, we will have enough bytes available.
    //
    // Remove buffers from the top of the queue until we have enough bytes.
    while (_byteQueue.isNotEmpty && awaiter.remaining > 0) {
      var top = _byteQueue.first;

      // If the amount is exactly the same, AND there are no bytes in the buffer,
      // just return the buffer itself.
      if (top.length == awaiter.remaining && awaiter.builder.isEmpty) {
        return new Future<Uint8List>.value(_byteQueue.removeFirst());
      }

      // If the buffer has less than or equal to the required number of bytes,
      // add it all and remove it.
      else if (top.length <= awaiter.remaining) {
        awaiter.builder.add(_byteQueue.removeFirst());
      }

      // Otherwise, add the necessary amount, and only leave
      // the remainder on the queue.
      else {
        var remainder =
            new Uint8List.view(top.buffer, top.offsetInBytes + length);
        var out = new Uint8List.view(top.buffer, top.offsetInBytes, length);
        _byteQueue.removeFirst();
        if (remainder.isNotEmpty) _byteQueue.addFirst(remainder);
        return new Future<Uint8List>.value(out);
      }
    }

    // If the awaiter is full, just return its value.
    if (awaiter.remaining <= 0) {
      return new Future<Uint8List>.value(
          castBytes(awaiter.builder.takeBytes()));
    }

    // Otherwise, enqueue it until further notice.
    _awaiterQueue.addLast(awaiter);
    return awaiter.completer.future;
  }

  @override
  Future<void> addStream(Stream<List<int>> stream) {
    return stream.map(castBytes).forEach((buf) {
      int index = 0;

      // Complete any possible awaiters.
      while (_awaiterQueue.isNotEmpty && index <= buf.length - 1) {
        var top = _awaiterQueue.first;

        // Dump out enqueued bytes into awaiters.

        while (_byteQueue.isNotEmpty && top.remaining > 0) {
          var topBytes = _byteQueue.removeFirst();

          if (topBytes.length <= top.remaining) {
            top.builder.add(topBytes);
          } else {
            var length = top.remaining;
            var remainder = new Uint8List.view(
                topBytes.buffer, topBytes.offsetInBytes + length);
            var out = new Uint8List.view(
                topBytes.buffer, topBytes.offsetInBytes, length);
            _byteQueue.removeFirst();
            if (remainder.isNotEmpty) _byteQueue.addFirst(remainder);
            return new Future<Uint8List>.value(out);
          }
        }

        if (top.remaining == 0) {
          _awaiterQueue.removeFirst();
          top.completer.complete(castBytes(top.builder.toBytes()));
          continue;
        }

        // If this is the first entry being added, and it is the exact size, add it.
        if (top.remaining == buf.length && top.builder.isEmpty) {
          _awaiterQueue.removeFirst();
          top.completer.complete(buf);
          return null;
        }

        // If the buffer has >= the size, add the whole thing.
        else if (top.remaining >= buf.length) {
          top.builder.add(buf);

          // Remove the awaiter if it's completed.
          if (top.remaining == 0) {
            _awaiterQueue.removeFirst();
            top.completer.complete(castBytes(top.builder.toBytes()));
          }

          return null;
        }

        // Otherwise, only add what is necessary.
        else {
          var out =
              new Uint8List.view(buf.buffer, buf.offsetInBytes, top.remaining);
          index += top.remaining;
          top.builder.add(out);

          // Remove the awaiter if it's completed.
          if (top.remaining == 0) {
            _awaiterQueue.removeFirst();
            top.completer.complete(castBytes(top.builder.toBytes()));
          } else {
            buf = new Uint8List.view(buf.buffer, buf.offsetInBytes + index);
          }

          // Enqueue all leftover data.
          if (index >= 0) {
            var leftover =
                new Uint8List.view(buf.buffer, buf.offsetInBytes + index);
            buf = leftover;
          }
        }
      }

      // Enqueue all leftover data.
      if (buf.isNotEmpty) {
        var leftover = buf;
        _byteQueue.addLast(leftover);
      }
    });
  }

  @override
  Future close() async {
    while (_awaiterQueue.isNotEmpty) {
      var awaiter = _awaiterQueue.removeFirst();
      awaiter.completer.completeError(
          new StateError(
              'Stream was closed before ${awaiter.fillLength} byte(s) could be read.'),
          awaiter.stackTrace);
    }
  }
}

class _ByteStreamReaderAwaiter {
  final Completer<Uint8List> completer = new Completer<Uint8List>();
  final StackTrace stackTrace;
  final BytesBuilder builder = new BytesBuilder();
  final int fillLength;

  _ByteStreamReaderAwaiter(this.stackTrace, this.fillLength);

  int get remaining => fillLength - builder.length;

  @override
  String toString() {
    return 'Awaiting $remaining/$fillLength';
  }
}
