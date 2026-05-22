import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:get/get.dart';

import 'package:fluxa_app/core/constants/app_colors.dart';
import 'package:fluxa_app/core/constants/app_spacing.dart';
import 'package:fluxa_app/core/constants/app_text_styles.dart';
import 'package:fluxa_app/features/profile/presentation/controllers/profile_controller.dart';

class UrutanMenuPage extends StatefulWidget {
  const UrutanMenuPage({super.key});

  @override
  State<UrutanMenuPage> createState() => _UrutanMenuPageState();
}

class _UrutanMenuPageState extends State<UrutanMenuPage> {
  late final ProfileController _controller;
  late List<String> _orderedIds;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileController>();
    _orderedIds = List<String>.from(_controller.orderedHomeMenuIds);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String movedItem = _orderedIds.removeAt(oldIndex);
      _orderedIds.insert(newIndex, movedItem);
    });
    _controller.updateHomeMenuOrder(_orderedIds);
  }

  void _resetOrder() {
    final List<String> defaults = ProfileController.homeMenus
        .map((HomeMenuDefinition menu) => menu.id)
        .toList(growable: false);
    setState(() {
      _orderedIds = List<String>.from(defaults);
    });
    _controller.updateHomeMenuOrder(_orderedIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Urutan Menu',
          style: AppTextStyles.roboto18w600.copyWith(
            color: AppColors.textPrimary,
            fontSize: 22,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _resetOrder,
            child: Text(
              'Atur Ulang',
              style: AppTextStyles.roboto14w500.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s4,
              AppSpacing.s16,
              AppSpacing.s12,
            ),
            child: Text(
              'Tekan lama dan geser untuk ganti posisi 4 menu utama.',
              style: AppTextStyles.roboto14w400.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final int selectedPaletteIndex =
                  _controller.selectedMenuPaletteIndex.value;
              if (_orderedIds.length != _controller.menuCount) {
                _orderedIds = List<String>.from(_controller.orderedHomeMenuIds);
              }
              return ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                itemCount: _orderedIds.length,
                onReorder: _onReorder,
                proxyDecorator:
                    (
                      Widget child,
                      int index,
                      Animation<double> animation,
                    ) {
                      return Material(
                        color: Colors.transparent,
                        child: child,
                      );
                    },
                itemBuilder: (BuildContext context, int index) {
                  final String id = _orderedIds[index];
                  final HomeMenuDefinition menu = _controller.findMenuById(id);
                  final Color accentColor = ProfileController
                      .menuColorPalettes[selectedPaletteIndex]
                      .colors[index];
                  return Container(
                    key: ValueKey<String>(id),
                    margin: const EdgeInsets.only(bottom: AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                        vertical: AppSpacing.s8,
                      ),
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: AppIcon(menu.icon, color: accentColor, size: 32),
                      ),
                      title: Text(
                        menu.label,
                        style: AppTextStyles.roboto18w600.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                      trailing: const AppIcon(
                        AppHugeIcons.drag_handle_rounded,
                        color: AppColors.textSecondary,
                        size: 30,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}




