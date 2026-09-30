import 'dart:async';

import 'package:PROJECT_NAME_PLACEHOLDER/models/app_error_model.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/providers/_mixins.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/utils/extensions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../features/auth/view/login_screen.dart';
import '../utils/app_build_methods.dart';
import '../utils/time_zone_helper.dart';
import 'api_service.dart';
import '_mixins_api.dart';

class WebAPIService with WebAPIMixin, MixinAPIProvider {
  static final WebAPIService _instance = WebAPIService._initialise();

  factory WebAPIService() => _instance;

  final Dio _dio;

  Dio get dio => _dio;

  static bool _isHandlingUnauthorized = false;

  /// Handles 401 Unauthorized or invalid credentials across any API call.
  /// Clears user token & session from storage, notifies user, and redirects to Login screen.
  static Future<void> handleUnauthorizedSession({String? message}) async {
    if (_isHandlingUnauthorized) return;
    _isHandlingUnauthorized = true;

    try {
      debugPrint(
          '[Auth] 401 Unauthorized / Invalid Credentials detected! Clearing token and redirecting to Login.');

      // 1. Clear saved token, headers, and user preferences
      await ApiService.instance.clearAuth();

      // 2. Show toast notification to user
      final toastMessage =
          message ?? 'Could not validate credentials. Please log in again.';
      showToast(toastMessage);

      // 3. Clear navigation stack and navigate to LoginScreen
      final navState = AppConfig.navKey.currentState;
      if (navState != null && navState.mounted) {
        final isAlreadyOnLogin =
            Navigator.of(navState.context).isCurrentRoute(LoginScreen.routeName);
        if (!isAlreadyOnLogin) {
          navState.pushNamedAndRemoveUntil(
            LoginScreen.routeName,
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('[Auth] Error in handleUnauthorizedSession: $e');
    } finally {
      // Cooldown timer to prevent repetitive toasts/navigations from concurrent API failures
      Future.delayed(const Duration(seconds: 2), () {
        _isHandlingUnauthorized = false;
      });
    }
  }

  /// Checks if a 200 response body contains unauthenticated / credential validation error
  static void _checkResponseForUnauthorized(Response response) {
    try {
      final path = response.requestOptions.path.toLowerCase();
      final isAuthEndpoint =
          path.contains('/auth/login') || path.endsWith('/login');
      if (isAuthEndpoint) return;

      final data = response.data;
      if (data is Map) {
        final detail = data['detail']?.toString().toLowerCase() ?? '';
        final message = (data['message'] ?? data['Message'] ?? data['error'])
                ?.toString()
                .toLowerCase() ??
            '';
        if (detail.contains('could not validate credentials') ||
            detail.contains('not authenticated') ||
            detail.contains('unauthenticated') ||
            message.contains('could not validate credentials') ||
            message.contains('unauthenticated') ||
            message.contains('invalid token') ||
            message.contains('token expired')) {
          handleUnauthorizedSession(
            message: data['detail']?.toString() ?? data['message']?.toString(),
          );
        }
      } else if (data is String) {
        final lower = data.toLowerCase();
        if (lower.contains('could not validate credentials') ||
            lower.contains('unauthenticated')) {
          handleUnauthorizedSession();
        }
      }
    } catch (e) {
      debugPrint('[Auth] Error in _checkResponseForUnauthorized: $e');
    }
  }

  /// Intercepts DioException to handle 401 Unauthorized or credential validation errors
  static Future<void> _handleDioErrorAuthCheck(DioException error) async {
    try {
      final path = error.requestOptions.path.toLowerCase();
      final isAuthEndpoint =
          path.contains('/auth/login') || path.endsWith('/login');
      // If the error comes from user attempting login, do not intercept as session expiration
      if (isAuthEndpoint) return;

      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      bool isUnauthorized = statusCode == 401;
      String? errorDetail;

      if (data is Map) {
        final detail = data['detail']?.toString() ?? '';
        final detailLower = detail.toLowerCase();
        final message = (data['message'] ?? data['Message'] ?? data['error'])
                ?.toString() ??
            '';
        final msgLower = message.toLowerCase();

        if (detail.isNotEmpty) {
          errorDetail = detail;
        } else if (message.isNotEmpty) {
          errorDetail = message;
        }

        if (detailLower.contains('could not validate credentials') ||
            detailLower.contains('not authenticated') ||
            detailLower.contains('unauthenticated') ||
            detailLower.contains('invalid token') ||
            msgLower.contains('could not validate credentials') ||
            msgLower.contains('unauthenticated') ||
            msgLower.contains('token expired') ||
            msgLower.contains('invalid token')) {
          isUnauthorized = true;
        }
      } else if (data is String) {
        final lower = data.toLowerCase();
        if (lower.contains('could not validate credentials') ||
            lower.contains('unauthenticated') ||
            lower.contains('not authenticated')) {
          isUnauthorized = true;
          errorDetail = data;
        }
      }

      if (isUnauthorized) {
        await handleUnauthorizedSession(message: errorDetail);
      }
    } catch (e) {
      debugPrint('[Auth] Error in _handleDioErrorAuthCheck: $e');
    }
  }

  WebAPIService._initialise()
      : _dio = Dio(BaseOptions(
            headers: {
              "accept": "application/json",
            })) {
    // Auth Interceptor: ensures every outgoing request gets the token from SharedPreferences or headers
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!options.headers.containsKey('Authorization') ||
              options.headers['Authorization'] == null ||
              options.headers['Authorization'].toString().isEmpty) {
            final token = await getTokenFromSharedPref();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          if (!options.headers.containsKey('timezone')) {
            options.headers['timezone'] = TimezoneHelper.userTimezone;
          }
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          _checkResponseForUnauthorized(response);
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          await _handleDioErrorAuthCheck(error);
          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        responseHeader: false,
        responseBody: true,
        requestBody: true,
        requestHeader: true,
      ));
      // ..interceptors.add(AppStackInterceptorBuilder.appStackInterceptor);
    }
  }

  Future<bool> initTokenToHeader({bool initToken = true}) =>
      getTokenFromSharedPref().then((token) {
        if (token?.isEmpty ?? true) {
          return true;
        }
        if (_dio.options.headers.containsKey('Authorization')) {
          _dio.options.headers.remove('Authorization');
        }
        if (initToken) {
          _dio.options.headers
              .putIfAbsent('Authorization', () => 'Bearer $token');
          debugPrint('Authorization==>${token!}');
        }
        return true;
      });

  ///initialize language code in header
  Future<bool> initLangPrefToHeader() =>
      getLanguageSharedPref().then((languageCode) async {
        if (_dio.options.headers.containsKey('lang')) {
          _dio.options.headers.remove('lang');
        }
        _dio.options.headers.putIfAbsent('lang', () => languageCode ?? 'en');
        return true;
      });

  /// Initializes the tenant code in the header.
  ///
  /// This function retrieves the tenant code from shared preferences and sets it
  /// in the Dio headers. If the 'tenant' header already exists, it is removed
  /// before setting the new tenant code.
  ///
  /// Returns a [Future] that completes with `true` when the tenant code is successfully set.
  Future<bool> initTenantPrefToHeader() =>
      getTenantCodeSharedPref().then((tenantCode) async {
        if (_dio.options.headers.containsKey('tenant')) {
          _dio.options.headers.remove('tenant');
        }
        _dio.options.headers.putIfAbsent('tenant', () => tenantCode ?? '0');
        return true;
      });

  /// Executes an API call and handles its response.
  ///
  /// This function performs the following steps:
  /// 1. Calls the provided API method.
  /// 2. Validates the response status and data.
  /// 3. Converts the response data using the provided converter function.
  /// 4. Calls the [onSuccess] callback if the response is successful.
  /// 5. Handles any errors using the [onDioError] function and calls the [onError] callback if provided.
  ///
  /// The function also supports refreshing the API call using the [functionToRefresh] parameter.
  ///
  /// - [methodToCall]: The API method to call, which returns a [Future] of [Response].
  /// - [converter]: A function to convert the response data.
  /// - [onError]: An optional callback for handling errors.
  /// - [onSuccess]: An optional callback for handling successful responses.
  /// - [functionToRefresh]: An optional function to refresh the API call.
  ///
  /// Returns a [Future] that completes with the converted response data.
  Future<T> executeAPI<T>({
    required Future<Response<dynamic>> methodToCall,
    required FutureOr<T> Function(
      Map<dynamic, dynamic> value,
    ) converter,
    Function(AppError msg)? onError,
    Function(T value)? onSuccess,
    Function? functionToRefresh,
  }) {
    return methodToCall
        .then(validateResStatusData)
        .then(converter)
        .then((value) {
      onSuccess?.call(value);
      return value;
    }).catchError((ex) {
      onDioError(ex, 'setRegistrationVerifyOTP',
          apiFunction: functionToRefresh);
      throw ex;
    }, test: (ex) => ex is DioException).handleAPIException(
      handleAPIException: handleAPIException,
      onShowError: (msg) {
        onError?.call(msg);
      },
    );
  }
}
