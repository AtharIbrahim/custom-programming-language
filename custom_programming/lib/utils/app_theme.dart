// utils/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Modern, dark theme configuration for the Compiler App
class AppTheme {
  AppTheme._();

  /// Main app theme with custom color scheme
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // =================== Color Scheme ===================
    colorScheme: const ColorScheme.dark(
      // Primary colors
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryVariant,
      onPrimaryContainer: AppColors.onSurface,
      
      // Secondary colors
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryDark,
      onSecondaryContainer: AppColors.onSurface,
      
      // Surface colors
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceVariant: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      
      // Background colors
      background: AppColors.background,
      onBackground: AppColors.onBackground,
      
      // Error colors
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      
      // Other colors
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
      shadow: Colors.black,
      scrim: Colors.black54,
    ),

    // =================== App Bar Theme ===================
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.appBar,
      foregroundColor: AppColors.onSurface,
      elevation: 2,
      shadowColor: Colors.black26,
      surfaceTintColor: AppColors.primary,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(
        color: AppColors.primary,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: AppColors.primary,
        size: 22,
      ),
    ),

    // =================== Elevated Button Theme ===================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // =================== Outlined Button Theme ===================
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // =================== Text Button Theme ===================
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.25,
        ),
      ),
    ),

    // =================== Floating Action Button Theme ===================
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      elevation: 6,
      highlightElevation: 12,
      shape: CircleBorder(),
      iconSize: 28,
    ),

    // =================== Card Theme ===================
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),

    // =================== Dialog Theme ===================
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 24,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        color: AppColors.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.onSurfaceVariant,
        fontSize: 16,
        height: 1.5,
      ),
    ),

    // =================== Bottom Sheet Theme ===================
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      elevation: 16,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    ),

    // =================== Tab Bar Theme ===================
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
    ),

    // =================== Input Decoration Theme ===================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: const TextStyle(
        color: AppColors.textTertiary,
        fontSize: 16,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // =================== Switch Theme ===================
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textTertiary;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary.withOpacity(0.5);
        }
        return AppColors.surfaceVariant;
      }),
    ),

    // =================== Slider Theme ===================
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.surfaceVariant,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary,
      valueIndicatorColor: AppColors.primary,
      valueIndicatorTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    // =================== Snack Bar Theme ===================
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      contentTextStyle: const TextStyle(
        color: AppColors.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      behavior: SnackBarBehavior.floating,
    ),

    // =================== Progress Indicator Theme ===================
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.surfaceVariant,
      circularTrackColor: AppColors.surfaceVariant,
    ),

    // =================== Divider Theme ===================
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // =================== Icon Theme ===================
    iconTheme: const IconThemeData(
      color: AppColors.onSurfaceVariant,
      size: 24,
    ),

    // =================== Text Theme ===================
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.onSurface,
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
      ),
      displayMedium: TextStyle(
        color: AppColors.onSurface,
        fontSize: 28,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        color: AppColors.onSurface,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        color: AppColors.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      headlineMedium: TextStyle(
        color: AppColors.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      headlineSmall: TextStyle(
        color: AppColors.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: AppColors.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      titleMedium: TextStyle(
        color: AppColors.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      titleSmall: TextStyle(
        color: AppColors.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        color: AppColors.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: AppColors.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        color: AppColors.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      labelLarge: TextStyle(
        color: AppColors.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
      ),
      labelMedium: TextStyle(
        color: AppColors.onSurface,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
      ),
      labelSmall: TextStyle(
        color: AppColors.onSurfaceVariant,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
      ),
    ),

    // =================== Visual Density & Platform ===================
    visualDensity: VisualDensity.adaptivePlatformDensity,
    
    // =================== Font Family ===================
    fontFamily: 'RobotoMono',
  );

  /// System UI overlay style for dark theme
  static const SystemUiOverlayStyle darkSystemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  );
}