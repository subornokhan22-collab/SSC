import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class TeacherAttachment {
  static const maxCount = 3;
  static const maxBytes = 3 * 1024 * 1024;
  static const maxOriginalImageBytes = 15 * 1024 * 1024;
  final String name;
  final String mimeType;
  final Uint8List bytes;
  TeacherAttachment(
      {required this.name, required this.mimeType, required Uint8List bytes})
      : bytes = Uint8List.fromList(bytes).asUnmodifiableView();
  bool get isPdf => mimeType == 'application/pdf';
  Map<String, String> toJson() =>
      {'mimeType': mimeType, 'data': base64Encode(bytes)};

  static void validate(List<TeacherAttachment> files) {
    if (files.length > maxCount)
      throw const FormatException('Attach at most 3 photos or PDFs.');
    var total = 0;
    for (final f in files) {
      total += f.bytes.length;
      if (f.bytes.isEmpty || total > maxBytes)
        throw const FormatException(
            'Attachments must fit within 3 MB combined.');
      if (!matchesType(f.bytes, f.mimeType))
        throw const FormatException('Use a valid JPEG, PNG, WebP or PDF file.');
    }
  }

  static bool matchesType(Uint8List bytes, String mime) {
    final h = latin1.decode(bytes.take(16).toList());
    return switch (mime) {
      'application/pdf' => h.startsWith('%PDF-'),
      'image/jpeg' => h.startsWith('\xff\xd8\xff'),
      'image/png' => h.startsWith('\x89PNG\r\n\x1a\n'),
      'image/webp' =>
        h.startsWith('RIFF') && h.length >= 12 && h.substring(8, 12) == 'WEBP',
      _ => false,
    };
  }

  static Future<TeacherAttachment> photo(String name, Uint8List bytes) async {
    if (bytes.length > maxOriginalImageBytes)
      throw const FormatException('Choose a photo smaller than 15 MB.');
    final jpeg = await compute(_preparePhoto, bytes);
    return TeacherAttachment(name: name, mimeType: 'image/jpeg', bytes: jpeg);
  }
}

Uint8List _preparePhoto(Uint8List bytes) {
  if (!['image/jpeg', 'image/png', 'image/webp']
      .any((m) => TeacherAttachment.matchesType(bytes, m))) {
    throw const FormatException('Use a JPEG, PNG or WebP photo.');
  }
  final decoder = img.findDecoderForData(bytes);
  final info = decoder?.startDecode(bytes);
  if (info == null ||
      info.width <= 0 ||
      info.height <= 0 ||
      info.width * info.height > 40000000) {
    throw const FormatException(
        'Photo is unreadable or exceeds 40 megapixels.');
  }
  final decoded = img.decodeImage(bytes, frame: 0);
  if (decoded == null)
    throw const FormatException('Could not read this photo.');
  var image = img.bakeOrientation(decoded);
  if (image.width > 1600 || image.height > 1600) {
    image = image.width >= image.height
        ? img.copyResize(image, width: 1600)
        : img.copyResize(image, height: 1600);
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 82));
}

/// Stop reading as soon as the bound is crossed, including for cloud-backed files.
Future<Uint8List> readTeacherFile(Stream<List<int>> stream, int limit) async {
  final result = BytesBuilder(copy: false);
  await for (final chunk in stream) {
    if (result.length + chunk.length > limit)
      throw const FormatException(
          'File is too large. Photos: 15 MB before resizing; PDFs: 3 MB.');
    result.add(chunk);
  }
  return result.takeBytes();
}
