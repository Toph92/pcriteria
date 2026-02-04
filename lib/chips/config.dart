import 'package:flutter/material.dart';

bool? desktopMode; // = true;

//enum ChipLayout { layout1, layout2 }

class ModernStyle {
  static const double cornerRadius = 16.0;
  static const double padding = 16.0;
  static const double iconSize = 20.0;
  static const double avatarSize = 28.0;
  static const double labelFontSize = 13.0;
  static const double contentFontSize = 17.0;
  static const double floatingLabelFontSize = 11.0;

  static const EdgeInsets margin = EdgeInsets.only(bottom: 8.0);
  static const EdgeInsets contentPadding = EdgeInsets.all(16.0);

  static BoxShadow get shadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.06),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );

  static BoxDecoration containerDecoration(bool isActive) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(cornerRadius),
    border: Border.all(
      color: isActive ? Colors.blue.shade400 : Colors.grey.shade200,
      width: isActive ? 2.0 : 1.0,
    ),
    boxShadow: [shadow],
  );

  static TextStyle get labelStyle => TextStyle(
    fontSize: labelFontSize,
    fontWeight: FontWeight.w500,
    color: Colors.grey.shade600,
    letterSpacing: -0.2,
  );

  static TextStyle get floatingLabelStyle => TextStyle(
    fontSize: floatingLabelFontSize,
    fontWeight: FontWeight.w600,
    color: Colors.blue.shade600,
    letterSpacing: -0.1,
  );

  static TextStyle get contentStyle => const TextStyle(
    fontSize: contentFontSize,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
    letterSpacing: -0.4,
  );

  static TextStyle get placeholderStyle => TextStyle(
    fontSize: contentFontSize,
    fontWeight: FontWeight.w400,
    color: Colors.grey.shade500,
    letterSpacing: -0.4,
  );
}
