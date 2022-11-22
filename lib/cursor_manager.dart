import 'package:flutter/services.dart';

class CursorData {
  // final param = <String, dynamic>{
  //     'device': device,
  //     'key': cursor.key ?? "",
  //     'buffer': buffer,
  //     'length': buffer?.length ?? -1,
  //     'x': cursor.hotx ?? 0.0,
  //     'y': cursor.hoty ?? 0.0,
  //     'scale_x': cursor.imageWidth ?? -1,
  //     'scale_y': cursor.imageHeight ?? -1
  //   }
  late String name;
  late Uint8List buffer;
  late double hotX;
  late double hotY;
  late int width;
  late int height;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'buffer': buffer,
      'hotX': hotX,
      'hotY': hotY,
      'width': width,
      'height': height
    };
  }
}

/// The cursor manager
class CursorManager {
  static const channel = SystemChannels.mouseCursor;
  static const createCursorKeyWindows = "createCustomCursor/windows";
  static const setCursorMethodWindows = "setCustomCursor/windows";
  static const deleteCursorMethodWindows = "deleteCustomCursor/windows";

  CursorManager._();
  static CursorManager instance = CursorManager._();
  // [Note]
  // The documentation from channel
  //
  // // This method allows creating a custom cursor with rawBGRA buffer, returns a
  // // string to identify the cursor.
  // static constexpr char kCreateCustomCursorMethod[] =
  //     "createCustomCursor/windows";
  // // A string, the custom cursor's name.
  // static constexpr char kCustomCursorNameKey[] = "name";
  // // A list of bytes, the custom cursor's rawBGRA buffer.
  // static constexpr char kCustomCursorBufferKey[] = "buffer";
  // // A double, the x coordinate of the custom cursor's hotspot, starting from
  // // left.
  // static constexpr char kCustomCursorHotXKey[] = "hotX";
  // // A double, the y coordinate of the custom cursor's hotspot, starting from top.
  // static constexpr char kCustomCursorHotYKey[] = "hotY";
  // // An int value for the width of the custom cursor.
  // static constexpr char kCustomCursorWidthKey[] = "width";
  // // An int value for the height of the custom cursor.
  // static constexpr char kCustomCursorHeightKey[] = "height";

  // // This method allows setting a custom cursor with a unique int64_t key of the
  // // custom cursor.
  // static constexpr char kSetCustomCursorMethod[] = "setCustomCursor/windows";

  // // This method allows deleting a custom cursor with a string key.
  // static constexpr char kDeleteCustomCursorMethod[] =
  //     "deleteCustomCursor/windows";
  Future<String> registerCursor(CursorData data) async {
    final cursorName = await channel.invokeMethod<String>(
        createCursorKeyWindows, data.toJson());
    assert(cursorName == data.name);
    return cursorName!;
  }

  Future<void> deleteCursor(String name) async {
    await channel.invokeMethod(deleteCursorMethodWindows, {
      "name": name
    });
  }

  Future<void> setSystemCursor(String name) async {
    await channel.invokeMethod(setCursorMethodWindows, {
      "name": name
    });
  }
}
