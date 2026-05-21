import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluxa_app/core/constants/app_colors.dart';
import 'package:fluxa_app/core/constants/app_spacing.dart';
import 'package:fluxa_app/core/constants/app_text_styles.dart';

class TampilanKartuPage extends StatelessWidget {
  const TampilanKartuPage({super.key});

  final List<Map<String, dynamic>> _themes = const [
    {'name': 'Biru Klasik', 'colors': [Color(0xFF4FACFE), Color(0xFF00F2FE)]},
    {'name': 'Pelangi', 'colors': [Color(0xFFFA709A), Color(0xFFFEE140)]},
    {'name': 'Laut Tosca', 'colors': [Color(0xFF00C6FB), Color(0xFF005BEA)]},
    {'name': 'Ungu Berry', 'colors': [Color(0xFF662D8C), Color(0xFFED1E79)]},
    {'name': 'Senja Jingga', 'colors': [Color(0xFFFF9A9E), Color(0xFFFECFE7)]},
    {'name': 'Aurora', 'colors': [Color(0xFF00C9FF), Color(0xFF92FE9D)]},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pilih Tema Kartu', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.s16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.s16,
          mainAxisSpacing: AppSpacing.s16,
          childAspectRatio: 1.5,
        ),
        itemCount: _themes.length,
        itemBuilder: (context, index) {
          final theme = _themes[index];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: theme['colors'],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (theme['colors'][0] as Color).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                theme['name'],
                style: AppTextStyles.roboto16w400.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
