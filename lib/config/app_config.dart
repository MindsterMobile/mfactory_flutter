import 'package:flutter/material.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/utils/enums.dart';

class AppConfig {
  static const appName = "Factory App";
  static const bundleId = "com.mindster.mfactory";
  static const designWidth = 360;
  static const designHeight = 791;

  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  GlobalKey bottomNavigationKey = GlobalKey();
  static bool isDebugMode = true;

  static EnumBuildEnvironment server = EnumBuildEnvironment.dg;
}
