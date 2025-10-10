// utils/app_colors.dart
import 'package:flutter/material.dart';

/// Modern, professional color scheme for the Compiler App
/// Based on a dark theme with vibrant accent colors and excellent contrast
class AppColors {
  // Private constructor
  AppColors._();

  // =================== Primary Colors ===================
  
  /// Main brand color - Deep blue with purple tint
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryVariant = Color(0xFF3730A3); // Indigo 700

  // =================== Secondary Colors ===================
  
  /// Accent color for highlights and success states
  static const Color secondary = Color(0xFF10B981); // Emerald 500
  static const Color secondaryLight = Color(0xFF34D399); // Emerald 400
  static const Color secondaryDark = Color(0xFF059669); // Emerald 600

  // =================== Surface & Background ===================
  
  /// Main app background
  static const Color background = Color(0xFF0F0F23); // Very dark navy
  static const Color backgroundLight = Color(0xFF1A1B3A); // Dark navy
  
  /// Card and elevated surfaces
  static const Color surface = Color(0xFF1E1E2E); // Dark surface
  static const Color surfaceLight = Color(0xFF2D2D3D); // Lighter surface
  static const Color surfaceVariant = Color(0xFF313244); // Surface variant
  
  /// Editor specific backgrounds
  static const Color editorBackground = Color(0xFF181825); // Very dark editor
  static const Color editorSurface = Color(0xFF1E1E2E); // Editor surface
  static const Color editorHeader = Color(0xFF313244); // Editor header
  
  // =================== Text Colors ===================
  
  /// Primary text color
  static const Color onSurface = Color(0xFFCDD6F4); // Light lavender
  static const Color onSurfaceVariant = Color(0xFFA6ADC8); // Muted lavender
  static const Color onBackground = Color(0xFFCDD6F4); // Light lavender
  
  /// Secondary text
  static const Color textSecondary = Color(0xFF9399B2); // Gray lavender
  static const Color textTertiary = Color(0xFF6C7086); // Darker gray
  static const Color textDisabled = Color(0xFF45475A); // Very dark gray
  
  // =================== Status Colors ===================
  
  /// Success states
  static const Color success = Color(0xFFA6E3A1); // Light green
  static const Color successContainer = Color(0xFF166534); // Dark green container
  static const Color onSuccess = Color(0xFF002106); // Text on success
  
  /// Error states  
  static const Color error = Color(0xFFF38BA8); // Light red/pink
  static const Color errorContainer = Color(0xFF7C2D12); // Dark red container
  static const Color onError = Color(0xFF2D0709); // Text on error
  
  /// Warning states
  static const Color warning = Color(0xFFFAB387); // Light orange
  static const Color warningContainer = Color(0xFF9A3412); // Dark orange container
  static const Color onWarning = Color(0xFF2D1B69); // Text on warning
  
  /// Info states
  static const Color info = Color(0xFF89DCEB); // Light cyan
  static const Color infoContainer = Color(0xFF0C4A6E); // Dark cyan container
  static const Color onInfo = Color(0xFF002540); // Text on info

  // =================== Syntax Highlighting ===================
  
  static const Color syntaxKeyword = Color(0xFFCBA6F7); // Purple for keywords
  static const Color syntaxString = Color(0xFFA6E3A1); // Green for strings
  static const Color syntaxNumber = Color(0xFFFAB387); // Orange for numbers
  static const Color syntaxComment = Color(0xFF6C7086); // Gray for comments
  static const Color syntaxFunction = Color(0xFF89B4FA); // Blue for functions
  static const Color syntaxOperator = Color(0xFFF9E2AF); // Yellow for operators

  // =================== Interactive Elements ===================
  
  /// Button colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonSurface = Color(0xFF313244);
  static const Color buttonDisabled = Color(0xFF45475A);
  
  /// Border colors
  static const Color border = Color(0xFF585B70); // Subtle border
  static const Color borderFocus = primary; // Focused border
  static const Color borderError = error; // Error border
  
  /// Divider colors
  static const Color divider = Color(0xFF45475A); // Subtle divider
  static const Color dividerLight = Color(0xFF585B70); // More visible divider

  // =================== Special UI Elements ===================
  
  /// Floating Action Button
  static const Color fab = secondary;
  static const Color fabShadow = Color(0xFF000000);
  
  /// App Bar
  static const Color appBar = surface;
  static const Color appBarElevated = surfaceLight;
  
  /// Tab indicators
  static const Color tabIndicator = primary;
  static const Color tabSelected = primary;
  static const Color tabUnselected = textSecondary;
  
  /// Selection colors
  static const Color selection = Color(0xFF6366F1); // Primary with opacity
  static const Color selectionHandle = primary;
  
  // =================== Connection Status Colors ===================
  
  /// Server connection status
  static const Color connected = success;
  static const Color connecting = warning;
  static const Color disconnected = error;
  
  // =================== Gradient Definitions ===================
  
  /// Primary gradient for special UI elements
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [secondaryLight, secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // =================== Helper Methods ===================
  
  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Get darker shade of a color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount should be between 0 and 1');
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
  
  /// Get lighter shade of a color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount should be between 0 and 1');
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}

/// Color scheme extensions for Material 3
extension AppColorsExtension on ColorScheme {
  /// Custom color extensions
  Color get primaryContainer => AppColors.primaryVariant;
  Color get secondaryContainer => AppColors.secondaryDark;
  Color get surfaceContainer => AppColors.surfaceVariant;
  Color get editorBackground => AppColors.editorBackground;
  Color get editorSurface => AppColors.editorSurface;
  Color get syntaxKeyword => AppColors.syntaxKeyword;
  Color get syntaxString => AppColors.syntaxString;
  Color get syntaxComment => AppColors.syntaxComment;
}