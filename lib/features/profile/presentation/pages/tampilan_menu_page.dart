import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluxa_app/core/constants/app_colors.dart';
import 'package:fluxa_app/core/constants/app_spacing.dart';
import 'package:fluxa_app/core/constants/app_text_styles.dart';

class TampilanMenuPage extends StatefulWidget {
  const TampilanMenuPage({super.key});

  @override
  State<TampilanMenuPage> createState() => _TampilanMenuPageState();
}

class _TampilanMenuPageState extends State<TampilanMenuPage> {
  String _selectedLayout = 'grid';

  final List<Map<String, dynamic>> _layouts = [
    {
      'id': 'grid',
      'name': 'Gaya Grid (Default)',
      'desc': 'Tombol menu berbentuk ikon kotak 2x2. Hemat ruang dan bersih.',
      'icon': Icons.grid_view_rounded,
    },
    {
      'id': 'list',
      'name': 'Gaya Daftar Detail',
      'desc': 'Tombol menu memanjang ke samping dengan deskripsi singkat kegunaan.',
      'icon': Icons.list_alt_rounded,
    },
    {
      'id': 'compact',
      'name': 'Gaya Compact List',
      'desc': 'Menu horizontal minimalis tanpa label berlebih. Sangat ringkas.',
      'icon': Icons.menu_open_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tampilan Menu', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pilih Gaya Layout Menu Beranda',
              style: AppTextStyles.roboto14w400.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            ..._layouts.map((layout) {
              final isSelected = _selectedLayout == layout['id'];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isSelected
                      ? const BorderSide(color: AppColors.primary, width: 2)
                      : BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
                ),
                elevation: isSelected ? 4 : 0,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedLayout = layout['id'] as String;
                    });
                    Get.snackbar(
                      'Layout Diubah',
                      'Tata letak menu akan disesuaikan pada pembaruan mendatang!',
                      backgroundColor: AppColors.primary,
                      colorText: Colors.white,
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.background,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            layout['icon'] as IconData,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                layout['name'] as String,
                                style: AppTextStyles.roboto16w400.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                layout['desc'] as String,
                                style: AppTextStyles.roboto12w400.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Sukses',
                  'Gaya layout menu utama berhasil diperbarui secara lokal!',
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                );
              },
              child: const Text('Simpan Konfigurasi Tampilan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
