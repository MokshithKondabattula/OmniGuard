import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// OmniGuard cybersecurity dark theme.
///
/// Palette
/// - bg            #0b0f17  (deep space)
/// - surface       #111826  (panel)
/// - surfaceAlt    #1a2433  (card)
/// - border        #1f2a3a
/// - primary       #6ee7ff  (cyan threat-line)
/// - accent        #7c5cff  (neural violet)
/// - success       #22d3a0
/// - warning       #f4b740
/// - danger        #ff5d73
class AppTheme {
  static const bg = Color(0xFF0B0F17);
  static const surface = Color(0xFF111826);
  static const surfaceAlt = Color(0xFF1A2433);
  static const border = Color(0xFF1F2A3A);
  static const primary = Color(0xFF6EE7FF);
  static const accent = Color(0xFF7C5CFF);
  static const success = Color(0xFF22D3A0);
  static const warning = Color(0xFFF4B740);
  static const danger = Color(0xFFFF5D73);
  static const textHi = Color(0xFFE6EDF7);
  static const textLo = Color(0xFF8A98AE);

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: textHi,
      displayColor: textHi,
    );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: primary,
        secondary: accent,
        error: danger,
        onPrimary: Color(0xFF001018),
        onSurface: textHi,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border),
        ),
      ),
      dividerTheme: const DividerThemeData(color: border, space: 1, thickness: 1),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: Color(0x336EE7FF),
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: IconThemeData(color: textLo),
        selectedLabelTextStyle: TextStyle(color: primary),
        unselectedLabelTextStyle: TextStyle(color: textLo),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary),
        ),
      ),
    );
  }
}
