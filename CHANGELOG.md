## 1.2.3

- Updated example, lints and pubspec content.

## 1.2.2

- Fix bug on duplicate null-terminated bytes.

## 1.2.1

- Support for efficiently reading null-terminated bytes.

## 1.2.0

- Perfomance optimizations. (Thanks to [insinfo]()https://github.com/insinfo))

## 1.1.1

- Fixed bug related to zero byte read at end of buffer.
  ([#8](https://github.com/isoos/buffer/pull/8) thanks to [adrianboyko](https://github.com/adrianboyko))

## 1.1.0

- Final null-safe release.

## 1.1.0-nullsafety.0

- Updated to null safety, no changes to external API.
  ([#6](https://github.com/isoos/buffer/pull/6) thanks to [TimWhiting](https://github.com/TimWhiting))

## 1.0.7

- Updated to modern Dart standards.
- `ByteDataReader.offsetInBytes`.

## 1.0.6

- Using `package:pedantic` as base of the lint rules.

## 1.0.5+1

- Fix `offsetInBytes` use.

## 1.0.5

- More efficient merge in `ByteDataReader`.

## 1.0.4

- Fix buffer processing bug.

## 1.0.3

- `ByteDataReader.readAhead`

## 1.0.2

- `byteLength`-driven read and write methods for integers.

## 1.0.1

- Fix return type of `ByteDataReader.read()`.

## 1.0.0

- Initial version.
