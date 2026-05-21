import 'package:flutter/material.dart';
import 'package:fluxa_app/core/constants/app_colors.dart';
import 'package:fluxa_app/core/constants/app_spacing.dart';

class TampilanMenuPage extends StatelessWidget {
  const TampilanMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan Tampilan Menu', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Text(
          'Halaman Tampilan Menu (Coming Soon)',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
