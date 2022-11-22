import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart' hide Image;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_custom_cursor/cursor_manager.dart';
import 'package:flutter_custom_cursor/flutter_custom_cursor.dart';
import 'package:flutter_custom_cursor/mouse_cursors.dart';
import 'package:image/image.dart' as img2;

late Uint8List memoryCursorDataRawBGRA;
late Uint8List memoryCursorDataRawPNG;
late String cursorName;

String imgPath =
    "C:\\projects\\rustdesk_flutter_custom_cursor\\example\\assets\\cursors\\data.png";
String imgRawPath =
    "C:\\projects\\rustdesk_flutter_custom_cursor\\example\\assets\\cursors\\data.raw";
late img2.Image img;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // read memory Cursor
  print("reading memory cursor");
  img = await getImage(imgPath);
  memoryCursorDataRawBGRA =
      (img.getBytes(format: img2.Format.bgra))!.buffer.asUint8List();
  File(imgRawPath).writeAsBytesSync(memoryCursorDataRawBGRA);
  memoryCursorDataRawPNG = File(imgPath).readAsBytesSync();
  cursorName = await CursorManager.instance.registerCursor(CursorData()
    ..name = "test"
    ..buffer = memoryCursorDataRawBGRA
    ..height = img.height
    ..width = img.width
    ..hotX = 0
    ..hotY = 0);
  // test delete
  print("test delete");
  await CursorManager.instance.deleteCursor("test");
  cursorName = await CursorManager.instance.registerCursor(CursorData()
      ..name = "test"
      ..buffer = memoryCursorDataRawBGRA
      ..height = img.height
      ..width = img.width
      ..hotX = 0
      ..hotY = 0);
  runApp(const MyApp());
}

Future<img2.Image> getImage(String path) async {
  img = img2.decodePng(File(path).readAsBytesSync())!;
  return img;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String msg = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    var style = const TextStyle(fontSize: 30);
    print("rebuild");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: ListView(
          children: [
            MouseRegion(
              cursor: FlutterCustomCursors.pencil,
              child: Text("Pencil Style, normally apply to edit mode",
                  style: style),
            ),
            MouseRegion(
              cursor: FlutterCustomCursors.erase,
              child: Text("Erase Style, normally apply to delete mode",
                  style: style),
            ),
            MouseRegion(
              cursor: FlutterCustomCursors.cutTop,
              child: Text("CutTop Style, normally apply to delete mode",
                  style: style),
            ),
            MouseRegion(
              cursor: FlutterCustomCursors.cutLeft,
              child: Text("CutLeft Style, normally apply to delete mode",
                  style: style),
            ),
            MouseRegion(
              cursor: FlutterCustomCursors.cutDown,
              child: Text("CutDown Style, normally apply to delete mode",
                  style: style),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text("Flutter Official  Click Cursor", style: style),
            ),
            MouseRegion(
              cursor: FlutterCustomMemoryImageCursor(
                  key: cursorName),
              child: Row(
                children: [
                  // Image.memory(memoryCursorDataRawPNG),
                  Text("Memory Image Here", style: style),
                ],
              ),
            ),
            Text("OUTPUT: ${msg}"),
            // TextButton(
            //     onPressed: () async {
            //       msg =
            //           "${await FlutterCustomCursorController.instance.getCursorCacheKey()}";
            //       setState(() {});
            //     },
            //     child: Text("Last Cursor Cache List")),
            // TextButton(
            //     onPressed: () async {
            //       final keys = await FlutterCustomCursorController.instance
            //               .getCursorCacheKey() ??
            //           [];
            //       for (final key in keys) {
            //         await FlutterCustomCursorController.instance.freeCache(key);
            //       }
            //       msg =
            //           "${await FlutterCustomCursorController.instance.getCursorCacheKey()}";
            //       setState(() {});
            //     },
            //     child: Text("free all cache")),
            // TextButton(
            //     onPressed: () async {
            //       msg =
            //           "${await FlutterCustomCursorController.instance.lastCursorKey()}";
            //       setState(() {});
            //     },
            //     child: Text("Last Cursor Key"))
          ],
        )),
      ),
    );
  }
}
