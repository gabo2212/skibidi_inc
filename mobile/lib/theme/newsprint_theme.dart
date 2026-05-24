import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewsprintColors {
  static const background = Color(0xFFF9F9F7);
  static const ink = Color(0xFF111111);
  static const muted = Color(0xFFE5E5E0);
  static const neutral100 = Color(0xFFF5F5F5);
  static const neutral500 = Color(0xFF737373);
  static const neutral700 = Color(0xFF404040);
  static const accent = Color(0xFFCC0000);
}

class NewsprintTheme {
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: NewsprintColors.ink,
        onPrimary: NewsprintColors.background,
        secondary: NewsprintColors.accent,
        onSecondary: NewsprintColors.background,
        surface: NewsprintColors.background,
        onSurface: NewsprintColors.ink,
        error: NewsprintColors.accent,
        onError: NewsprintColors.background,
        outline: NewsprintColors.ink,
      ),
    );

    final textTheme = _textTheme(base.textTheme);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: NewsprintColors.background,
        foregroundColor: NewsprintColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.jetBrainsMono(
          color: NewsprintColors.ink,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
        shape: const Border(bottom: BorderSide(color: NewsprintColors.ink)),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: NewsprintColors.background,
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: NewsprintColors.ink),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: NewsprintColors.background,
        selectedColor: NewsprintColors.ink,
        disabledColor: NewsprintColors.muted,
        labelStyle: GoogleFonts.jetBrainsMono(
          color: NewsprintColors.ink,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.7,
        ),
        secondaryLabelStyle: GoogleFonts.jetBrainsMono(
          color: NewsprintColors.background,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.7,
        ),
        side: const BorderSide(color: NewsprintColors.ink),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      dividerTheme: const DividerThemeData(
        color: NewsprintColors.ink,
        thickness: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _buttonStyle(
          background: NewsprintColors.ink,
          foreground: NewsprintColors.background,
          border: NewsprintColors.ink,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonStyle(
          background: Colors.transparent,
          foreground: NewsprintColors.ink,
          border: NewsprintColors.ink,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NewsprintColors.ink,
          minimumSize: const Size(44, 44),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: NewsprintColors.ink,
          minimumSize: const Size(44, 44),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        labelStyle: GoogleFonts.jetBrainsMono(
          color: NewsprintColors.neutral700,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
        floatingLabelStyle: GoogleFonts.jetBrainsMono(
          color: NewsprintColors.ink,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: NewsprintColors.ink, width: 2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: NewsprintColors.accent, width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: NewsprintColors.accent, width: 2),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: NewsprintColors.accent, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: NewsprintColors.ink,
        contentTextStyle: GoogleFonts.lora(
          color: NewsprintColors.background,
          fontSize: 14,
        ),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: NewsprintColors.ink,
        textColor: NewsprintColors.ink,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: NewsprintColors.ink,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        color: NewsprintColors.ink,
        fontSize: 64,
        height: 0.9,
        fontWeight: FontWeight.w900,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        color: NewsprintColors.ink,
        fontSize: 42,
        height: 0.98,
        fontWeight: FontWeight.w900,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        color: NewsprintColors.ink,
        fontSize: 34,
        height: 1,
        fontWeight: FontWeight.w800,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        color: NewsprintColors.ink,
        fontSize: 28,
        height: 1.05,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        color: NewsprintColors.ink,
        fontSize: 24,
        height: 1.05,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: GoogleFonts.jetBrainsMono(
        color: NewsprintColors.ink,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
      titleSmall: GoogleFonts.jetBrainsMono(
        color: NewsprintColors.neutral700,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
      bodyLarge: GoogleFonts.lora(
        color: NewsprintColors.ink,
        fontSize: 16,
        height: 1.58,
      ),
      bodyMedium: GoogleFonts.lora(
        color: NewsprintColors.ink,
        fontSize: 14,
        height: 1.58,
      ),
      bodySmall: GoogleFonts.jetBrainsMono(
        color: NewsprintColors.neutral500,
        fontSize: 11,
        height: 1.45,
        letterSpacing: 0.4,
      ),
      labelLarge: GoogleFonts.jetBrainsMono(
        color: NewsprintColors.ink,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
      labelMedium: GoogleFonts.jetBrainsMono(
        color: NewsprintColors.ink,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        color: NewsprintColors.neutral500,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }

  static ButtonStyle _buttonStyle({
    required Color background,
    required Color foreground,
    required Color border,
  }) {
    return ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      side: WidgetStatePropertyAll(BorderSide(color: border)),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return NewsprintColors.muted;
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return background == NewsprintColors.ink
              ? NewsprintColors.background
              : NewsprintColors.ink;
        }
        return background;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return NewsprintColors.neutral500;
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return background == NewsprintColors.ink
              ? NewsprintColors.ink
              : NewsprintColors.background;
        }
        return foreground;
      }),
      textStyle: WidgetStatePropertyAll(
        GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}
