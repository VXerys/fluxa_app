import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CategoryColorParser {
  CategoryColorParser._();

  static Color parse(String? hex, {Color fallback = AppColors.primary}) {
    if (hex == null || hex.isEmpty) return fallback;

    final value = hex.replaceAll('#', '').trim();
    if (value.length != 6) return fallback;

    try {
      return Color(int.parse('FF$value', radix: 16));
    } on FormatException {
      return fallback;
    }
  }
}
