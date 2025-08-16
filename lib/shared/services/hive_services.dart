import 'package:hive_flutter/hive_flutter.dart';
import 'package:mylife/core/constants/color_constants.dart';

class HiveService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    // abrir la box de settings (crea si no existe)
    await Hive.openBox(ColorConstants.settingsBox);
    _initialized = true;
  }

  static Box<dynamic> get settingsBox {
    if (!Hive.isBoxOpen(ColorConstants.settingsBox)) {
      throw Exception('Settings box not open — call HiveService.init() first');
    }
    return Hive.box(ColorConstants.settingsBox);
  }
}
