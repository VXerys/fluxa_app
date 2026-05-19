import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  final String message;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.roboto16w400),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Text(message, style: AppTextStyles.lora24w400),
      ),
    );
  }
}
