import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const _urlFromDefine = String.fromEnvironment('SUPABASE_URL');
  static const _publishableKeyFromDefine =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const _webAuthCallbackUrlFromDefine = String.fromEnvironment(
    'SUPABASE_WEB_AUTH_CALLBACK_URL',
  );
  static const nativeAuthCallbackUrl =
      'com.omedacore.notelytask://auth-callback';

  static Future<void> loadEnv() async {
    await dotenv.load(
      fileName: 'assets/env/notelytask.env',
      isOptional: true,
    );
  }

  static String get url => _value(
        defineValue: _urlFromDefine,
        envKey: 'SUPABASE_URL',
      );

  static String get publishableKey => _value(
        defineValue: _publishableKeyFromDefine,
        envKey: 'SUPABASE_PUBLISHABLE_KEY',
      );

  static String get webAuthCallbackUrl => _value(
        defineValue: _webAuthCallbackUrlFromDefine,
        envKey: 'SUPABASE_WEB_AUTH_CALLBACK_URL',
        fallback: 'https://notelytask.dbilgin.com/auth-callback',
      );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  static String get authCallbackUrl =>
      kIsWeb ? webAuthCallbackUrl : nativeAuthCallbackUrl;

  static SupabaseClient? get client {
    if (!isConfigured) {
      return null;
    }
    return Supabase.instance.client;
  }

  static String _value({
    required String defineValue,
    required String envKey,
    String fallback = '',
  }) {
    if (defineValue.isNotEmpty) {
      return defineValue;
    }
    if (!dotenv.isInitialized) {
      return fallback;
    }
    return dotenv.maybeGet(envKey) ?? fallback;
  }
}
