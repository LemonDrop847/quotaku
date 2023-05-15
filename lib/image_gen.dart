import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<File?> generateImage(String quoteText, String signature) async {
  GlobalKey containerKey = GlobalKey();

  Widget container = RepaintBoundary(
    key: containerKey,
    child: Container(
      // key: containerKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            quoteText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 35,
              fontFamily: 'Fallscoming',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '-$signature',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Merriweather',
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ),
  );

  try {
    RenderRepaintBoundary boundary = containerKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}/image.png';
    File file = File(tempPath);
    await file.writeAsBytes(pngBytes);

    return file;
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
