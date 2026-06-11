import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> saveImage(Uint8List imageBytes, String fileName) async {
    final path = await _localPath;
    final file = File('\$path/$fileName');
    return file.writeAsBytes(imageBytes);
  }

  static Future<Uint8List?> loadImage(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return file.readAsBytes();
    }
    return null;
  }

  static Future<img.Image?> decodeImage(Uint8List bytes) async {
    try {
      return img.decodeImage(bytes);
    } catch (e) {
      return null;
    }
  }

  static Uint8List encodePng(img.Image image) {
    return img.encodePng(image);
  }

  static Uint8List encodeJpg(img.Image image, {int quality = 85}) {
    return img.encodeJpg(image, quality: quality);
  }

  static Future<Uint8List?> resizeImage(
    Uint8List bytes, {
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    final image = await decodeImage(bytes);
    if (image == null) return null;

    final resized = img.copyResize(
      image,
      width: image.width > maxWidth ? maxWidth : image.width,
      height: image.height > maxHeight ? maxHeight : image.height,
      interpolation: img.Interpolation.linear,
    );

    return Uint8List.fromList(encodePng(resized));
  }
}
