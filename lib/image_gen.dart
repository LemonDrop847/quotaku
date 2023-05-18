import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareCardAsImage(
    GlobalKey repaintKey, String quote, String details) async {
  RenderRepaintBoundary boundary =
      repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  if (boundary.debugNeedsPaint) {
    print("Waiting for boundary to be painted.");
    await Future.delayed(const Duration(milliseconds: 20));
    return shareCardAsImage(repaintKey, quote, details);
  }
  ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  Uint8List bytes = byteData!.buffer.asUint8List();

  final directory = await getTemporaryDirectory();
  final imagePath = '${directory.path}/quotaku_card.png';
  final imageFile = File(imagePath);
  await imageFile.writeAsBytes(bytes);

  final textToShare = '$quote\n\n-$details';
  await Share.shareFiles([imagePath], text: textToShare);
}
