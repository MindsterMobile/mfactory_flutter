import 'package:flutter/material.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/utils/enums.dart';

class AppConfig {
  static const appName = "APP_NAME_PLACEHOLDER";
  static const bundleId = "BUNDLE_ID_PLACEHOLDER";
  static const designWidth = WIDTH_PLACEHOLDER;
  static const designHeight = HEIGHT_PLACEHOLDER;

  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  GlobalKey bottomNavigationKey = GlobalKey();
  static bool isDebugMode = true;

  static EnumBuildEnvironment server = EnumBuildEnvironment.dg;
}
