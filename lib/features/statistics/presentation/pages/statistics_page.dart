import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:fluxa_app/core/widgets/app_empty_state.dart';
import 'package:fluxa_app/core/widgets/placeholder_page.dart';
import 'package:fluxa_app/core/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/category_color_parser.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../domain/entities/category_breakdown_entity.dart';
import '../../domain/entities/top_expense_transaction_entity.dart';
import '../controllers/statistics_controller.dart';

class StatisticsPage extends GetView<StatisticsController> {
  const StatisticsPage({super.key});
  static const int _maxCategoryCards = 5;

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
        bottom: false,
        child: RefreshIndicator(
          onRefresh: controller.loadStatistics,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Statistik',
                            style: AppTextStyles.lora24w400.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        _buildPeriodTabs(),
                        const SizedBox(height: AppSpacing.s12),
                        _buildPeriodNavigator(context),
                        const SizedBox(height: AppSpacing.s16),
                        _buildTypeToggle(),
                        const SizedBox(height: AppSpacing.s16),
                        _buildDonutChartArea(_amountFormatter),
                        const SizedBox(height: AppSpacing.s20),
                        _buildCategoryBreakdownSection(_amountFormatter),
                        const SizedBox(height: AppSpacing.s20),
                        _buildTopCategorySection(_amountFormatter),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              );
            },
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
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: tabs
              .map(
                (tab) => Expanded(
                  key: ValueKey(tab.value),
                  child: GestureDetector(
                    onTap: () => controller.changePeriod(tab.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 38,
                      decoration: BoxDecoration(
                        color: controller.selectedPeriod == tab.value
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.0),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: controller.selectedPeriod == tab.value
                                ? Colors.black.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.0),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tab.label,
                        style: AppTextStyles.roboto14w400.copyWith(
                          color: controller.selectedPeriod == tab.value
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: controller.selectedPeriod == tab.value
                              ? FontWeight.w600
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
        return Center(
          child: InkWell(
            onTap: () async {
              final now = DateTime.now();
              final DateTime rawStart =
                  controller.rangeStart ??
                  DateTime(now.year, now.month, now.day - 6);
              final DateTime rawEnd =
                  controller.rangeEnd ?? DateTime(now.year, now.month, now.day);
              final DateTime initialStart = rawStart.isAfter(rawEnd)
                  ? rawEnd
                  : rawStart;
              final DateTime initialEnd = rawStart.isAfter(rawEnd)
                  ? rawStart
                  : rawEnd;

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
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s8,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.04),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppIcon(
                    AppHugeIcons.calendar_today_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    controller.periodLabel,
                    style: AppTextStyles.roboto14w500.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s4),
                  const AppIcon(
                    AppHugeIcons.keyboard_arrow_down_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.04),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => controller.navigatePeriod(-1),
              icon: const AppIcon(AppHugeIcons.chevron_left_rounded, size: 20),
              color: AppColors.textSecondary,
              splashRadius: 20,
            ),
            Expanded(
              child: Center(
                child: Text(
                  controller.periodLabel,
                  style: AppTextStyles.roboto14w500.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => controller.navigatePeriod(1),
              icon: const AppIcon(AppHugeIcons.chevron_right_rounded, size: 20),
              color: AppColors.textSecondary,
              splashRadius: 20,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _TypeToggleItem(
                label: 'Pemasukan',
                icon: AppHugeIcons.arrow_upward,
                isActive: controller.selectedType == 'income',
                activeColor: AppColors.success,
                onTap: () => controller.changeType('income'),
              ),
            ),
            Expanded(
              child: _TypeToggleItem(
                label: 'Pengeluaran',
                icon: AppHugeIcons.arrow_downward,
                isActive: controller.selectedType == 'expense',
                activeColor: AppColors.error,
                onTap: () => controller.changeType('expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChartArea(NumberFormat amountFormatter) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isLoading) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final breakdown =
            controller.summary?.breakdown ?? <CategoryBreakdownEntity>[];
        if (controller.errorMessage.isNotEmpty && breakdown.isEmpty) {
          return SizedBox(
            height: 200,
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
          return const AppEmptyState(
            icon: AppHugeIcons.receipt,
            title: 'Belum Ada Transaksi',
            message: 'Catat transaksi Anda hari ini untuk melihat analisis keuangan di sini.',
            isCompact: true,
          );
        }

        final legendItems = breakdown.take(5).toList();
        final bool isExpense = controller.selectedType == 'expense';

        return SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 50,
                        sectionsSpace: 3,
                        sections: breakdown
                            .map(
                              (category) => PieChartSectionData(
                                value: category.percentage,
                                color: CategoryColorParser.parse(
                                  category.categoryColor,
                                  fallback: AppColors.primary,
                                ),
                                title: '',
                                radius: 30,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isExpense ? 'Pengeluaran' : 'Pemasukan',
                              style: AppTextStyles.roboto12w400.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              NumberFormat.currency(
                                locale: 'id_ID',
                                symbol: 'Rp',
                                decimalDigits: 0,
                              ).format(controller.summary?.totalAmount ?? 0),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.roboto16w600.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: legendItems
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.s6,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
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
                                  item.categoryName,
                                  style: AppTextStyles.roboto12w400.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s8),
                              Text(
                                '${item.percentage.toStringAsFixed(0)}%',
                                style: AppTextStyles.roboto12w400.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
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

  Widget _buildCategoryBreakdownSection(NumberFormat amountFormatter) {
    return Obx(() {
      if (controller.isLoading) return const SizedBox.shrink();

      final breakdown =
          controller.summary?.breakdown ?? <CategoryBreakdownEntity>[];
      if (breakdown.isEmpty) return const SizedBox.shrink();
      final visibleBreakdown = breakdown.take(_maxCategoryCards).toList();
      final bool hasMoreBreakdown = breakdown.length > _maxCategoryCards;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rincian Kategori',
            style: AppTextStyles.lora24w400.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: visibleBreakdown.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s12),
            itemBuilder: (_, index) {
              final item = visibleBreakdown[index];
              return _CategoryBreakdownCard(
                item: item,
                amountFormatter: amountFormatter,
              );
            },
          ),
          if (hasMoreBreakdown) ...[
            const SizedBox(height: AppSpacing.s8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: controller.openMoreTransactions,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Rincian kategori lainnya',
                  style: AppTextStyles.roboto14w500.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildDropdownChip<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T> onChanged,
  }) {
    return PopupMenuButton<T>(
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 4,
      offset: const Offset(0, 36),
      itemBuilder: (context) {
        return items.map((item) {
          final isSelected = item == value;
          return PopupMenuItem<T>(
            value: item,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.black.withValues(alpha: 0.06)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.toString(),
                style: AppTextStyles.roboto14w400.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              style: AppTextStyles.roboto12w400.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const AppIcon(
              AppHugeIcons.keyboard_arrow_down_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategorySection(NumberFormat amountFormatter) {
    return Obx(() {
      if (controller.isLoading) return const SizedBox.shrink();

      final topItems = controller.topTransactions;
      if (topItems.isEmpty) return const SizedBox.shrink();

      final String titlePrefix = controller.selectedType == 'income'
          ? 'Pemasukan'
          : 'Pengeluaran';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s16,
          AppSpacing.s16,
          AppSpacing.s14,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.04),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$titlePrefix Terbesar',
              style: AppTextStyles.lora24w400.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                _buildDropdownChip<String>(
                  value: controller.selectedGroupType,
                  items: const ['Kategori', 'Subkategori', 'Judul', 'Dompet'],
                  onChanged: controller.changeGroupType,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(topItems.length, (index) {
                final item = topItems[index];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TopTransactionItem(
                      item: item,
                      amountFormatter: amountFormatter,
                      rank: index + 1,
                    ),
                    if (index != topItems.length - 1)
                      const Divider(height: AppSpacing.s16, thickness: 0.5),
                  ],
                );
              }),
            ),
            if (controller.hasMoreTopTransactions) ...[
              const SizedBox(height: AppSpacing.s8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: controller.openMoreTransactions,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s12,
                    ),
                  ),
                  child: Text(
                    'Transaksi lainnya',
                    style: AppTextStyles.roboto14w500.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _TopTransactionItem extends StatelessWidget {
  final TopExpenseTransactionEntity item;
  final NumberFormat amountFormatter;
  final int rank;

  const _TopTransactionItem({
    required this.item,
    required this.amountFormatter,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('d MMM yyyy', 'id_ID');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: AppTextStyles.roboto12w400.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.roboto14w500.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.groupLabel} - ${dateFormatter.format(item.date)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.roboto12w400.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Text(
            amountFormatter.format(item.amount),
            style: AppTextStyles.roboto14w500.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            final statsController = Get.find<StatisticsController>();
            final nextDay = statsController.periodEnd.add(const Duration(days: 1));
            Get.toNamed(
              AppRoutes.transactionList,
              arguments: <String, dynamic>{
                'source': 'statistics',
                'type': statsController.selectedType,
                'startDate': statsController.periodStart.toIso8601String(),
                'endDateExclusive': nextDay.toIso8601String(),
                'categoryId': item.categoryId,
                'categoryName': item.categoryName,
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(
                    CategoryIconMapper.fromKey(item.categoryIcon),
                    color: categoryColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.categoryName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.roboto14w500.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          Text(
                            amountFormatter.format(item.amount),
                            style: AppTextStyles.roboto14w500.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double maxWidth = constraints.maxWidth;
                          return Stack(
                            children: [
                              Container(
                                width: maxWidth,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Container(
                                width: maxWidth * progress,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: categoryColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.transactionCount} transaksi',
                            style: AppTextStyles.roboto12w400.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${item.percentage.toStringAsFixed(0)}%',
                            style: AppTextStyles.roboto12w400.copyWith(
                              color: categoryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeToggleItem extends StatelessWidget {
  final String label;
  final AppIconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeToggleItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              icon,
              color: isActive ? activeColor : AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.s6),
            Text(
              label,
              style: AppTextStyles.roboto14w500.copyWith(
                color: isActive ? activeColor : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
