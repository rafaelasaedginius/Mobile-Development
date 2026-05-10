import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class StylizingService {
  Interpreter? _interpreter;
  static const int inputSize = 512;

  Future<void> loadModel() async {
    try {
      final byteData = await rootBundle.load('assets/cartoongan.tflite');
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/cartoongan.tflite');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      _interpreter = await Interpreter.fromFile(tempFile);
    } catch (e) {
      throw Exception('Gagal load model: $e');
    }
  }

  Future<Uint8List?> transferStyle(File imageFile) async {
    if (_interpreter == null) await loadModel();

    final rawBytes = await imageFile.readAsBytes();
    img.Image? originalImage = img.decodeImage(rawBytes);
    if (originalImage == null) return null;

    img.Image resized = img.copyResize(
      originalImage,
      width: inputSize,
      height: inputSize,
    );

    var inputTensor = List.generate(
      1,
          (_) => List.generate(
        inputSize,
            (y) => List.generate(
          inputSize,
              (x) {
            final pixel = resized.getPixel(x, y);
            return [
              (pixel.r / 127.5) - 1.0,
              (pixel.g / 127.5) - 1.0,
              (pixel.b / 127.5) - 1.0,
            ];
          },
        ),
      ),
    );

    var outputTensor = List.generate(
      1,
          (_) => List.generate(
        inputSize,
            (_) => List.generate(
          inputSize,
              (_) => List.filled(3, 0.0),
        ),
      ),
    );

    _interpreter!.run(inputTensor, outputTensor);

    img.Image outputImage = img.Image(width: inputSize, height: inputSize);
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final r = ((outputTensor[0][y][x][0] + 1.0) * 127.5).clamp(0, 255).toInt();
        final g = ((outputTensor[0][y][x][1] + 1.0) * 127.5).clamp(0, 255).toInt();
        final b = ((outputTensor[0][y][x][2] + 1.0) * 127.5).clamp(0, 255).toInt();
        outputImage.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return Uint8List.fromList(img.encodePng(outputImage));
  }

  void dispose() {
    _interpreter?.close();
  }
}