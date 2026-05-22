import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/category_color_parser.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../domain/entities/category_breakdown_entity.dart';
import '../controllers/statistics_controller.dart';

class StatisticsPage extends GetView<StatisticsController> {
  const StatisticsPage({super.key});

  static final NumberFormat _amountFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Statistik', style: AppTextStyles.roboto18w600),
              const SizedBox(height: AppSpacing.s16),
              _buildPeriodTabs(),
              const SizedBox(height: AppSpacing.s12),
              _buildPeriodNavigator(context),
              const SizedBox(height: AppSpacing.s20),
              _buildTypeToggle(),
              const SizedBox(height: AppSpacing.s20),
              _buildDonutChartArea(_amountFormatter),
              const SizedBox(height: AppSpacing.s16),
              _buildCategoryBreakdownSection(_amountFormatter),
              const SizedBox(height: AppSpacing.s12),
              _buildTopCategorySection(_amountFormatter),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodTabs() {
    final tabs = <({String label, String value})>[
      (label: 'Mingguan', value: 'weekly'),
      (label: 'Bulanan', value: 'monthly'),
      (label: 'Tahunan', value: 'yearly'),
      (label: 'Rentang', value: 'range'),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Obx(
        () => Row(
          children: tabs
              .map(
                (tab) => Expanded(
                  child: GestureDetector(
                    onTap: () => controller.changePeriod(tab.value),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: controller.selectedPeriod == tab.value
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tab.label,
                        style: AppTextStyles.roboto14w400.copyWith(
                          color: controller.selectedPeriod == tab.value
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: controller.selectedPeriod == tab.value
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildPeriodNavigator(BuildContext context) {
    return Obx(() {
      if (controller.selectedPeriod == 'range') {
        return InkWell(
          onTap: () async {
            final now = DateTime.now();
            final initialStart =
                controller.rangeStart ?? DateTime(now.year, now.month, now.day - 6);
            final initialEnd =
                controller.rangeEnd ?? DateTime(now.year, now.month, now.day);

            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000, 1, 1),
              lastDate: DateTime(2100, 12, 31),
              initialDateRange: DateTimeRange(
                start: initialStart,
                end: initialEnd,
              ),
              locale: const Locale('id', 'ID'),
            );
            if (picked == null) return;
            controller.setRange(picked.start, picked.end);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.s8),
                Text(
                  controller.periodLabel,
                  style: AppTextStyles.roboto16w600.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Row(
        children: [
          IconButton(
            onPressed: () => controller.navigatePeriod(-1),
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Center(
              child: Text(
                controller.periodLabel,
                style: AppTextStyles.roboto16w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => controller.navigatePeriod(1),
            icon: const Icon(Icons.chevron_right_rounded),
            color: AppColors.textPrimary,
          ),
        ],
      );
    });
  }

  Widget _buildTypeToggle() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _TypeToggleItem(
              label: 'Pemasukan',
              isActive: controller.selectedType == 'income',
              activeBackground: AppColors.success.withOpacity(0.1),
              activeTextColor: AppColors.success,
              onTap: () => controller.changeType('income'),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: _TypeToggleItem(
              label: 'Pengeluaran',
              isActive: controller.selectedType == 'expense',
              activeBackground: AppColors.error.withOpacity(0.1),
              activeTextColor: AppColors.error,
              onTap: () => controller.changeType('expense'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChartArea(NumberFormat amountFormatter) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Obx(() {
        if (controller.isLoading) {
          return const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final breakdown = controller.summary?.breakdown ??
            <CategoryBreakdownEntity>[];
        if (controller.errorMessage.isNotEmpty && breakdown.isEmpty) {
          return SizedBox(
            height: 280,
            child: Center(
              child: Text(
                controller.errorMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.roboto14w400.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }
        if (breakdown.isEmpty) {
          return SizedBox(
            height: 280,
            child: Center(
              child: Text(
                'Tidak ada data',
                style: AppTextStyles.roboto14w400.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        final legendItems = breakdown.take(5).toList();
        return SizedBox(
          height: 280,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 80,
                        sectionsSpace: 2,
                        sections: breakdown
                            .map(
                              (category) => PieChartSectionData(
                                value: category.percentage,
                                color: CategoryColorParser.parse(
                                  category.categoryColor,
                                  fallback: AppColors.primary,
                                ),
                                title: '',
                                radius: 26,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total',
                          style: AppTextStyles.roboto12w400.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          amountFormatter.format(
                            controller.summary?.totalAmount ?? 0,
                          ),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.roboto14w500.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: legendItems
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.s6,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: CategoryColorParser.parse(
                                    item.categoryColor,
                                    fallback: AppColors.primary,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s8),
                              Expanded(
                                child: Text(
                                  _truncateCategoryName(item.categoryName),
                                  style: AppTextStyles.roboto12w400.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s6),
                              Text(
                                '${item.percentage.toStringAsFixed(0)}%',
                                style: AppTextStyles.roboto12w400.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _truncateCategoryName(String name) {
    if (name.length <= 10) return name;
    return '${name.substring(0, 10)}...';
  }

  Widget _buildCategoryBreakdownSection(NumberFormat amountFormatter) {
    return Obx(() {
      if (controller.isLoading) return const SizedBox.shrink();

      final breakdown = controller.summary?.breakdown ?? <CategoryBreakdownEntity>[];
      if (breakdown.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rincian Kategori', style: AppTextStyles.roboto16w600),
          const SizedBox(height: AppSpacing.s10),
          ListView.separated(
            itemCount: breakdown.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s10),
            itemBuilder: (_, index) {
              final item = breakdown[index];
              return _CategoryBreakdownCard(
                item: item,
                amountFormatter: amountFormatter,
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildTopCategorySection(NumberFormat amountFormatter) {
    return Obx(() {
      if (controller.isLoading) return const SizedBox.shrink();

      final topItems = (controller.summary?.breakdown ?? <CategoryBreakdownEntity>[])
          .take(5)
          .toList();
      if (topItems.isEmpty) return const SizedBox.shrink();

      final String titlePrefix =
          controller.selectedType == 'income' ? 'Pemasukan' : 'Pengeluaran';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$titlePrefix Terbesar',
              style: AppTextStyles.roboto16w600.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s10),
            Wrap(
              spacing: AppSpacing.s8,
              children: const [
                _StaticChoiceChip(label: 'Kategori'),
                _StaticChoiceChip(label: 'Top 5'),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            ListView.separated(
              itemCount: topItems.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s10),
              itemBuilder: (_, index) {
                final item = topItems[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.roboto12w400.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.roboto14w500.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            '${item.transactionCount} transaksi',
                            style: AppTextStyles.roboto12w400.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Text(
                      amountFormatter.format(item.amount),
                      style: AppTextStyles.roboto14w400.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  final CategoryBreakdownEntity item;
  final NumberFormat amountFormatter;

  const _CategoryBreakdownCard({
    required this.item,
    required this.amountFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final Color categoryColor = CategoryColorParser.parse(
      item.categoryColor,
      fallback: AppColors.primary,
    );
    final double progress = (item.percentage / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CategoryIconMapper.fromKey(item.categoryIcon),
              color: categoryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.categoryName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.roboto16w600.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxWidth = constraints.maxWidth;
                    return Stack(
                      children: [
                        Container(
                          width: maxWidth,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Container(
                          width: maxWidth * progress,
                          height: 6,
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  '${item.transactionCount} transaksi',
                  style: AppTextStyles.roboto12w400.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.percentage.toStringAsFixed(0)}%',
                style: AppTextStyles.roboto16w600.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
              Text(
                amountFormatter.format(item.amount),
                style: AppTextStyles.roboto14w400.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StaticChoiceChip extends StatelessWidget {
  final String label;

  const _StaticChoiceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 14),
        ],
      ),
      selected: true,
      showCheckmark: false,
      onSelected: (_) {},
      labelStyle: AppTextStyles.roboto12w400.copyWith(
        color: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.background,
      selectedColor: AppColors.background,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
    );
  }
}

class _TypeToggleItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeBackground;
  final Color activeTextColor;
  final VoidCallback onTap;

  const _TypeToggleItem({
    required this.label,
    required this.isActive,
    required this.activeBackground,
    required this.activeTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? activeBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeTextColor : AppColors.neutral,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.roboto14w500.copyWith(
            color: isActive ? activeTextColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
