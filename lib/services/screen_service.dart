import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ScreenService {
  static const _channel = MethodChannel(
    'com.hassadi.libyaratesboard/device',
  );

  static Future<void> setFullScreen(bool enabled) async {
    if (enabled) {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );
    } else {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
    }
  }

  static Future<void> setStayAwake(bool enabled) async {
    if (enabled) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }
  }

  static Future<bool> openCastSettings() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'openCastSettings',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
