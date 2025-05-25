import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

enum AppTheme {
  defaultDark,
  oceanBlue,
  forestGreen,
  sunsetOrange,
  purpleNight,
  rosePink,
}

class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryVariant = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryVariant = Color(0xFF059669);

  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceVariant = Color(0xFF334155);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFF1F5F9);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);

  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  static const Color divider = Color(0xFF475569);
  static const Color border = Color(0xFF64748B);
}

class OceanBlueColors {
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryVariant = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color secondaryVariant = Color(0xFF0284C7);

  static const Color background = Color(0xFF0C1220);
  static const Color surface = Color(0xFF1A2332);
  static const Color surfaceVariant = Color(0xFF2A3441);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFF1F5F9);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);

  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  static const Color divider = Color(0xFF475569);
  static const Color border = Color(0xFF64748B);
}

class ForestGreenColors {
  static const Color primary = Color(0xFF10B981);
  static const Color primaryVariant = Color(0xFF059669);
  static const Color secondary = Color(0xFF22C55E);
  static const Color secondaryVariant = Color(0xFF16A34A);

  static const Color background = Color(0xFF0C1A14);
  static const Color surface = Color(0xFF1A2B20);
  static const Color surfaceVariant = Color(0xFF2A3D32);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFF1F5F9);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);

  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  static const Color divider = Color(0xFF475569);
  static const Color border = Color(0xFF64748B);
}

class SunsetOrangeColors {
  static const Color primary = Color(0xFFF97316);
  static const Color primaryVariant = Color(0xFFEA580C);
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryVariant = Color(0xFFD97706);

  static const Color background = Color(0xFF1A120C);
  static const Color surface = Color(0xFF2B1F1A);
  static const Color surfaceVariant = Color(0xFF3D2F2A);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFF1F5F9);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);

  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  static const Color divider = Color(0xFF475569);
  static const Color border = Color(0xFF64748B);
}

class PurpleNightColors {
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryVariant = Color(0xFF7C3AED);
  static const Color secondary = Color(0xFFA855F7);
  static const Color secondaryVariant = Color(0xFF9333EA);

  static const Color background = Color(0xFF14101A);
  static const Color surface = Color(0xFF251E2B);
  static const Color surfaceVariant = Color(0xFF372F3D);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFF1F5F9);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);

  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  static const Color divider = Color(0xFF475569);
  static const Color border = Color(0xFF64748B);
}

class RosePinkColors {
  static const Color primary = Color(0xFFE11D48);
  static const Color primaryVariant = Color(0xFFBE123C);
  static const Color secondary = Color(0xFFEC4899);
  static const Color secondaryVariant = Color(0xFFDB2777);

  static const Color background = Color(0xFF1A0C14);
  static const Color surface = Color(0xFF2B1A25);
  static const Color surfaceVariant = Color(0xFF3D2A37);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFF1F5F9);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);

  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  static const Color divider = Color(0xFF475569);
  static const Color border = Color(0xFF64748B);
}

class ThemeHelper {
  static Map<String, Color> getThemeColors(AppTheme theme) {
    switch (theme) {
      case AppTheme.defaultDark:
        return {
          'primary': AppColors.primary,
          'secondary': AppColors.secondary,
          'background': AppColors.background,
          'surface': AppColors.surface,
        };
      case AppTheme.oceanBlue:
        return {
          'primary': OceanBlueColors.primary,
          'secondary': OceanBlueColors.secondary,
          'background': OceanBlueColors.background,
          'surface': OceanBlueColors.surface,
        };
      case AppTheme.forestGreen:
        return {
          'primary': ForestGreenColors.primary,
          'secondary': ForestGreenColors.secondary,
          'background': ForestGreenColors.background,
          'surface': ForestGreenColors.surface,
        };
      case AppTheme.sunsetOrange:
        return {
          'primary': SunsetOrangeColors.primary,
          'secondary': SunsetOrangeColors.secondary,
          'background': SunsetOrangeColors.background,
          'surface': SunsetOrangeColors.surface,
        };
      case AppTheme.purpleNight:
        return {
          'primary': PurpleNightColors.primary,
          'secondary': PurpleNightColors.secondary,
          'background': PurpleNightColors.background,
          'surface': PurpleNightColors.surface,
        };
      case AppTheme.rosePink:
        return {
          'primary': RosePinkColors.primary,
          'secondary': RosePinkColors.secondary,
          'background': RosePinkColors.background,
          'surface': RosePinkColors.surface,
        };
    }
  }

  static String getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.defaultDark:
        return 'Default Dark';
      case AppTheme.oceanBlue:
        return 'Ocean Blue';
      case AppTheme.forestGreen:
        return 'Forest Green';
      case AppTheme.sunsetOrange:
        return 'Sunset Orange';
      case AppTheme.purpleNight:
        return 'Purple Night';
      case AppTheme.rosePink:
        return 'Rose Pink';
    }
  }
}

ThemeData getThemeData(AppTheme theme) {
  late Map<String, Color> colors;

  switch (theme) {
    case AppTheme.defaultDark:
      colors = {
        'primary': AppColors.primary,
        'primaryVariant': AppColors.primaryVariant,
        'secondary': AppColors.secondary,
        'secondaryVariant': AppColors.secondaryVariant,
        'background': AppColors.background,
        'surface': AppColors.surface,
        'surfaceVariant': AppColors.surfaceVariant,
        'onPrimary': AppColors.onPrimary,
        'onSurface': AppColors.onSurface,
        'onSurfaceVariant': AppColors.onSurfaceVariant,
        'error': AppColors.error,
        'warning': AppColors.warning,
        'success': AppColors.success,
        'divider': AppColors.divider,
        'border': AppColors.border,
      };
      break;
    case AppTheme.oceanBlue:
      colors = {
        'primary': OceanBlueColors.primary,
        'primaryVariant': OceanBlueColors.primaryVariant,
        'secondary': OceanBlueColors.secondary,
        'secondaryVariant': OceanBlueColors.secondaryVariant,
        'background': OceanBlueColors.background,
        'surface': OceanBlueColors.surface,
        'surfaceVariant': OceanBlueColors.surfaceVariant,
        'onPrimary': OceanBlueColors.onPrimary,
        'onSurface': OceanBlueColors.onSurface,
        'onSurfaceVariant': OceanBlueColors.onSurfaceVariant,
        'error': OceanBlueColors.error,
        'warning': OceanBlueColors.warning,
        'success': OceanBlueColors.success,
        'divider': OceanBlueColors.divider,
        'border': OceanBlueColors.border,
      };
      break;
    case AppTheme.forestGreen:
      colors = {
        'primary': ForestGreenColors.primary,
        'primaryVariant': ForestGreenColors.primaryVariant,
        'secondary': ForestGreenColors.secondary,
        'secondaryVariant': ForestGreenColors.secondaryVariant,
        'background': ForestGreenColors.background,
        'surface': ForestGreenColors.surface,
        'surfaceVariant': ForestGreenColors.surfaceVariant,
        'onPrimary': ForestGreenColors.onPrimary,
        'onSurface': ForestGreenColors.onSurface,
        'onSurfaceVariant': ForestGreenColors.onSurfaceVariant,
        'error': ForestGreenColors.error,
        'warning': ForestGreenColors.warning,
        'success': ForestGreenColors.success,
        'divider': ForestGreenColors.divider,
        'border': ForestGreenColors.border,
      };
      break;
    case AppTheme.sunsetOrange:
      colors = {
        'primary': SunsetOrangeColors.primary,
        'primaryVariant': SunsetOrangeColors.primaryVariant,
        'secondary': SunsetOrangeColors.secondary,
        'secondaryVariant': SunsetOrangeColors.secondaryVariant,
        'background': SunsetOrangeColors.background,
        'surface': SunsetOrangeColors.surface,
        'surfaceVariant': SunsetOrangeColors.surfaceVariant,
        'onPrimary': SunsetOrangeColors.onPrimary,
        'onSurface': SunsetOrangeColors.onSurface,
        'onSurfaceVariant': SunsetOrangeColors.onSurfaceVariant,
        'error': SunsetOrangeColors.error,
        'warning': SunsetOrangeColors.warning,
        'success': SunsetOrangeColors.success,
        'divider': SunsetOrangeColors.divider,
        'border': SunsetOrangeColors.border,
      };
      break;
    case AppTheme.purpleNight:
      colors = {
        'primary': PurpleNightColors.primary,
        'primaryVariant': PurpleNightColors.primaryVariant,
        'secondary': PurpleNightColors.secondary,
        'secondaryVariant': PurpleNightColors.secondaryVariant,
        'background': PurpleNightColors.background,
        'surface': PurpleNightColors.surface,
        'surfaceVariant': PurpleNightColors.surfaceVariant,
        'onPrimary': PurpleNightColors.onPrimary,
        'onSurface': PurpleNightColors.onSurface,
        'onSurfaceVariant': PurpleNightColors.onSurfaceVariant,
        'error': PurpleNightColors.error,
        'warning': PurpleNightColors.warning,
        'success': PurpleNightColors.success,
        'divider': PurpleNightColors.divider,
        'border': PurpleNightColors.border,
      };
      break;
    case AppTheme.rosePink:
      colors = {
        'primary': RosePinkColors.primary,
        'primaryVariant': RosePinkColors.primaryVariant,
        'secondary': RosePinkColors.secondary,
        'secondaryVariant': RosePinkColors.secondaryVariant,
        'background': RosePinkColors.background,
        'surface': RosePinkColors.surface,
        'surfaceVariant': RosePinkColors.surfaceVariant,
        'onPrimary': RosePinkColors.onPrimary,
        'onSurface': RosePinkColors.onSurface,
        'onSurfaceVariant': RosePinkColors.onSurfaceVariant,
        'error': RosePinkColors.error,
        'warning': RosePinkColors.warning,
        'success': RosePinkColors.success,
        'divider': RosePinkColors.divider,
        'border': RosePinkColors.border,
      };
      break;
  }

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: colors['primary']!,
      primaryContainer: colors['primaryVariant']!,
      secondary: colors['secondary']!,
      secondaryContainer: colors['secondaryVariant']!,
      surface: colors['surface']!,
      surfaceContainerHighest: colors['surfaceVariant']!,
      onPrimary: colors['onPrimary']!,
      onSurface: colors['onSurface']!,
      onSurfaceVariant: colors['onSurfaceVariant']!,
      error: colors['error']!,
    ),
    scaffoldBackgroundColor: colors['background']!,
    appBarTheme: AppBarTheme(
      backgroundColor: colors['surface']!,
      foregroundColor: colors['onSurface']!,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: colors['primary']!,
      titleTextStyle: TextStyle(
        color: colors['onSurface']!,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(
        color: colors['onSurface']!,
      ),
    ),
    cardTheme: CardThemeData(
      color: colors['surface']!,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors['primary']!,
        foregroundColor: colors['onPrimary']!,
        elevation: 2,
        shadowColor: colors['primary']!.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors['primary']!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: colors['onSurfaceVariant']!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors['primary']!,
      foregroundColor: colors['onPrimary']!,
      elevation: 4,
      shape: const CircleBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors['surfaceVariant']!.withValues(alpha: 0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors['border']!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors['border']!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors['primary']!, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors['error']!),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: TextStyle(color: colors['onSurfaceVariant']!),
      labelStyle: TextStyle(color: colors['onSurfaceVariant']!),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: colors['onSurface']!,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: colors['onSurface']!,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      displaySmall: TextStyle(
        color: colors['onSurface']!,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: TextStyle(
        color: colors['onSurface']!,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: colors['onSurface']!,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        color: colors['onSurface']!,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        color: colors['onSurface']!,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: colors['onSurface']!,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: colors['onSurfaceVariant']!,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: colors['onSurface']!,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: colors['onSurface']!,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        color: colors['onSurfaceVariant']!,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
      labelLarge: TextStyle(
        color: colors['onSurface']!,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: colors['onSurfaceVariant']!,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: colors['onSurfaceVariant']!,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colors['divider']!,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors['surface']!,
      contentTextStyle: TextStyle(color: colors['onSurface']!),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 4,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors['surface']!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors['surface']!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      elevation: 8,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      titleTextStyle: TextStyle(
        color: colors['onSurface']!,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      subtitleTextStyle: TextStyle(
        color: colors['onSurfaceVariant']!,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors['primary']!,
      selectionColor: colors['primary']!,
      selectionHandleColor: colors['primary']!,
    ),
  );
}

final themeData = getThemeData(AppTheme.defaultDark);

final defaultPinTheme = PinTheme(
  width: 56,
  height: 56,
  textStyle: const TextStyle(
    fontSize: 20,
    color: AppColors.onSurface,
    fontWeight: FontWeight.w600,
  ),
  decoration: BoxDecoration(
    color: AppColors.surfaceVariant.withValues(alpha: 0.3),
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(12),
  ),
);

final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  border: Border.all(color: AppColors.primary, width: 2),
  color: AppColors.surface,
);

final submittedPinTheme = defaultPinTheme.copyWith(
  decoration: defaultPinTheme.decoration?.copyWith(
    color: AppColors.primary.withValues(alpha: 0.1),
    border: Border.all(color: AppColors.primary),
  ),
);
