import 'package:PROJECT_NAME_PLACEHOLDER/config/app_config.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/utils/enums.dart';

class UrlHelpers {
  static EnumBuildEnvironment get server => AppConfig.server;

  static String get baseURL {
    switch (server) {
      case EnumBuildEnvironment.live:
        return 'https://mi-factory.aufy.net/';
      case EnumBuildEnvironment.uat:
        return 'https://mi-factory.aufy.net/';
      case EnumBuildEnvironment.dg:
        return 'https://mi-factory.aufy.net/';
    }
  }

  static String get key {
    switch (server) {
      case EnumBuildEnvironment.live:
        return '';
      case EnumBuildEnvironment.uat:
        return '';
      case EnumBuildEnvironment.dg:
        return '';
    }
  }

  static String get baseUrlApi {
    return '${baseURL}api/v1/';
  }
}
