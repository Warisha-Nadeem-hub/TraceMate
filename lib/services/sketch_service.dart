import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../models/sketch_item.dart';

class SketchService {
  Future<Uint8List?> generatePencilSketch(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    final grayscale = img.grayscale(image);
    final inverted = img.invert(
      img.copyResize(
        grayscale,
        width: grayscale.width,
        height: grayscale.height,
      ),
    );
    final blurred = img.gaussianBlur(inverted, radius: 10);
    final result = img.Image(width: grayscale.width, height: grayscale.height);

    for (int y = 0; y < result.height; y++) {
      for (int x = 0; x < result.width; x++) {
        final g = grayscale.getPixel(x, y);
        final b = blurred.getPixel(x, y);

        // Directly access the red channel (or any color channel since it is grayscale)
        final grey = (((g.r) + (b.r)) ~/ 2).clamp(0, 255).toInt();

        result.setPixelRgb(x, y, grey, grey, grey);
      }
    }

    final normalized = img.normalize(result, min: 0, max: 255);
    return Uint8List.fromList(img.encodePng(normalized));
  }

  Future<Uint8List?> generateOutlineSketch(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    final grayscale = img.grayscale(image);
    final edged = img.sobel(grayscale);
    final inverted = img.invert(edged);
    return Uint8List.fromList(img.encodePng(inverted));
  }

  Future<Uint8List?> generateHighContrastSketch(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    final grayscale = img.grayscale(image);
    final contrast = img.adjustColor(grayscale, contrast: 1.5);
    return Uint8List.fromList(img.encodePng(contrast));
  }

  Future<Uint8List?> generateSmoothSketch(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    final grayscale = img.grayscale(image);
    final blurred = img.gaussianBlur(grayscale, radius: 5);
    return Uint8List.fromList(img.encodePng(blurred));
  }

  Future<Uint8List?> generateArtisticSketch(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    final grayscale = img.grayscale(image);
    final contrast = img.adjustColor(grayscale, contrast: 1.8);
    final sepia = img.sepia(contrast);
    return Uint8List.fromList(img.encodePng(sepia));
  }

  Future<Uint8List?> generateComicSketch(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    final grayscale = img.grayscale(image);
    final contrasted = img.adjustColor(grayscale, contrast: 2.0);
    final quantized = img.quantize(contrasted, numberOfColors: 8);
    return Uint8List.fromList(img.encodePng(quantized));
  }

  Future<Uint8List?> generateSketch(
    Uint8List imageBytes,
    SketchType type,
  ) async {
    switch (type) {
      case SketchType.pencilSketch:
        return generatePencilSketch(imageBytes);
      case SketchType.outlineSketch:
        return generateOutlineSketch(imageBytes);
      case SketchType.highContrastSketch:
        return generateHighContrastSketch(imageBytes);
      case SketchType.smoothSketch:
        return generateSmoothSketch(imageBytes);
      case SketchType.artisticSketch:
        return generateArtisticSketch(imageBytes);
      case SketchType.comicSketch:
        return generateComicSketch(imageBytes);
      case SketchType.drawSketch:
        return generatePencilSketch(imageBytes);
    }
  }

  Future<String?> saveSketch(Uint8List imageBytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final sketchesDir = Directory('${directory.path}/sketches');
      if (!await sketchesDir.exists()) {
        await sketchesDir.create(recursive: true);
      }
      final file = File('${sketchesDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }
}
