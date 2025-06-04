import 'package:flutter/foundation.dart';
import '../models/platform_model.dart';

class PlatformController {
  static PlatformModel getPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return PlatformModel(name: 'Android');
      case TargetPlatform.iOS:
        return PlatformModel(name: 'iOS');
      default:
        return PlatformModel(name: 'Other');
    }
  }
}