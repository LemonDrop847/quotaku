import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<File?> shareImage(String quoteText, String signature) async {
  GlobalKey globalKey = GlobalKey();

  RepaintBoundary(
    key: globalKey,
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
  );

  try {
    print('inside');
    RenderRepaintBoundary? boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
    ui.Image? image = await boundary?.toImage(pixelRatio: 3.0);
    ByteData? byteData =
        await image!.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData!.buffer.asUint8List();
    var bs64 = base64Encode(pngBytes);
    print(pngBytes);
    print(bs64);
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
