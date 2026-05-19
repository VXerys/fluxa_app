import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Naming convention: <font><size>w<weight> e.g. roboto16w400

  // Roboto (UI)
  static const TextStyle roboto12w400 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle roboto14w400 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle roboto16w400 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle roboto18w500 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Lora (Display)
  static const TextStyle lora24w400 = TextStyle(
    fontFamily: 'Lora',
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle lora36w400 = TextStyle(
    fontFamily: 'Lora',
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
}
