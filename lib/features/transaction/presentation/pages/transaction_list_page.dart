import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:fluxa_app/core/widgets/app_empty_state.dart';
import 'package:fluxa_app/core/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/category_color_parser.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../domain/entities/transaction_entity.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/transaction_filter_widget.dart';
import '../widgets/transaction_item_widget.dart';
import 'transaction_detail_page.dart';

class TransactionListPage extends GetView<TransactionController> {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Log Transaksi',
          style: AppTextStyles.roboto18w600.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const AppIcon(
            AppHugeIcons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: _TransactionListBody(controller: controller),
    );
  }
}

class _TransactionListBody extends StatefulWidget {
  final TransactionController controller;

  const _TransactionListBody({required this.controller});

  @override
  State<_TransactionListBody> createState() => _TransactionListBodyState();
}

class _TransactionListBodyState extends State<_TransactionListBody> {
  bool _didApplyRoutePrefilter = false;
  final TextEditingController _searchTextController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didApplyRoutePrefilter) return;
    _didApplyRoutePrefilter = true;

    final dynamic args = Get.arguments;
    if (args is Map<String, dynamic> && args['source'] == 'statistics') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.applyStatisticsPrefilter(args);
      });
    }
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  List<TransactionEntity> _applyLocalSearch(List<TransactionEntity> items) {
    final query = widget.controller.searchQuery.toLowerCase();
    if (query.isEmpty) return items;

    return items.where((item) {
      final titleMatch = item.note?.toLowerCase().contains(query) ?? false;
      final categoryMatch =
          item.category?.name.toLowerCase().contains(query) ?? false;
      return titleMatch || categoryMatch;
    }).toList();
  }

  Future<void> _confirmDelete(TransactionEntity transaction) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Transaksi', style: AppTextStyles.roboto16w400),
          content: Text(
            'Transaksi ini akan dihapus. Lanjutkan?',
            style: AppTextStyles.roboto14w400,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: Text('Batal', style: AppTextStyles.roboto14w400),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text('Hapus', style: AppTextStyles.roboto14w400),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await widget.controller.deleteTransaction(transaction.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.controller.isLoading && widget.controller.transactions.isEmpty) {
        return _buildShimmerList();
      }

      final hasActiveFilters = widget.controller.searchQuery.isNotEmpty ||
          widget.controller.filterType != 'Semua' ||
          widget.controller.filterCategory != null ||
          widget.controller.filterDateRange != 'Semua Waktu' ||
          widget.controller.filterNominal != 'Rentang Nominal';

      if (widget.controller.transactions.isEmpty && !hasActiveFilters) {
        return AppEmptyState(
          icon: AppHugeIcons.receipt,
          title: 'Belum Ada Transaksi',
          message: 'Mulai catat transaksi Anda untuk melacak keuangan dengan rapi!',
          actionLabel: 'Tambah Transaksi',
          onActionPressed: () => Get.toNamed(Routes.addTransaction),
        );
      }

      final List<TransactionEntity> filtered = _applyLocalSearch(
        widget.controller.transactions,
      );

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            child: TextField(
              controller: _searchTextController,
              onChanged: widget.controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Cari transaksi...',
                hintStyle: AppTextStyles.roboto14w400.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const AppIcon(
                  AppHugeIcons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          TransactionFilterWidget(
            onOpenTypeFilter: _showTypeFilterBottomSheet,
            onOpenCategoryFilter: _showCategoryFilterBottomSheet,
            onOpenDateFilter: _showDateFilterBottomSheet,
            onOpenSortFilter: _showSortFilterBottomSheet,
            onOpenNominalFilter: _showNominalFilterBottomSheet,
            onOpenWalletFilter: () {}, // Wallet is static for now
          ),
          const SizedBox(height: AppSpacing.s8),
          Expanded(
            child: filtered.isEmpty
                ? AppEmptyState(
                    icon: AppHugeIcons.search,
                    title: 'Tidak Ada Transaksi Cocok',
                    message: 'Coba ubah kata kunci pencarian Anda atau reset filter.',
                    actionLabel: 'Reset Filter',
                    onActionPressed: () {
                      _searchTextController.clear();
                      widget.controller.setSearchQuery('');
                      widget.controller.setFilterType('Semua');
                      widget.controller.setFilterCategory(null);
                      widget.controller.setFilterDateRange('Semua Waktu');
                      widget.controller.setFilterNominal('Rentang Nominal');
                    },
                    isCompact: true,
                  )
                : RefreshIndicator(
                    onRefresh: widget.controller.loadTransactions,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => Divider(
                        color: AppColors.neutral.withValues(alpha: 0.1),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final transaction = filtered[index];

                        return GestureDetector(
                          onTap: () => Get.to(
                            () => TransactionDetailPage(transaction: transaction),
                          ),
                          onLongPress: () => _confirmDelete(transaction),
                          child: TransactionItemWidget(transaction: transaction),
                        );
                      },
                    ),
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s8),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.background,
          highlightColor: AppColors.surface,
          child: Container(
            height: AppSpacing.s48 + AppSpacing.s16,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.s12),
            ),
          ),
        );
      },
    );
  }

  void _showTypeFilterBottomSheet() {
    final options = ['Semua', 'Pemasukan', 'Pengeluaran'];
    _showOptionsBottomSheet(
      'Tipe Transaksi',
      options,
      widget.controller.filterType,
      (val) {
        widget.controller.setFilterType(val);
      },
    );
  }

  void _showDateFilterBottomSheet() {
    final options = ['Semua Waktu', 'Bulan Ini', 'Minggu Ini', 'Hari Ini'];
    _showOptionsBottomSheet(
      'Rentang Waktu',
      options,
      widget.controller.filterDateRange,
      (val) {
        widget.controller.setFilterDateRange(val);
      },
    );
  }

  void _showSortFilterBottomSheet() {
    final options = [
      'Tanggal (Terbaru)',
      'Tanggal (Terlama)',
      'Nominal Tertinggi',
      'Nominal Terendah',
    ];
    _showOptionsBottomSheet(
      'Urutkan',
      options,
      widget.controller.filterSortBy,
      (val) {
        widget.controller.setFilterSortBy(val);
      },
    );
  }

  void _showNominalFilterBottomSheet() {
    final options = ['Semua', '< 50.000', '50.000 - 100.000', '> 100.000'];
    _showOptionsBottomSheet(
      'Rentang Nominal',
      options,
      widget.controller.filterNominal == 'Rentang Nominal'
          ? 'Semua'
          : widget.controller.filterNominal,
      (val) {
        widget.controller.setFilterNominal(val);
      },
    );
  }

  void _showOptionsBottomSheet(
    String title,
    List<String> options,
    String selected,
    ValueChanged<String> onSelect,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(title, style: AppTextStyles.roboto16w600),
            const SizedBox(height: AppSpacing.s16),
            ...options.map(
              (option) => ListTile(
                title: Text(option, style: AppTextStyles.roboto14w400),
                trailing: selected == option
                    ? const AppIcon(AppHugeIcons.check, color: AppColors.textPrimary)
                    : null,
                onTap: () {
                  onSelect(option);
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showCategoryFilterBottomSheet() {
    final categories = widget.controller.visibleFilterCategories
        .where((category) => category.parentId == null)
        .toList();
    final allCategories = widget.controller.filterCategories;
    final parentNameById = {
      for (final category in allCategories.where(
        (item) => item.parentId == null,
      ))
        category.id: category.name,
    };

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text('Kategori', style: AppTextStyles.roboto16w600),
            const SizedBox(height: AppSpacing.s16),
            SizedBox(
              height: Get.height * 0.45,
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: Text(
                      'Semua Kategori',
                      style: AppTextStyles.roboto14w400,
                    ),
                    trailing: widget.controller.filterCategory == null
                        ? const AppIcon(AppHugeIcons.check, color: AppColors.textPrimary)
                        : null,
                    onTap: () {
                      widget.controller.setFilterCategory(null);
                      Get.back();
                    },
                  ),
                  ...categories.map((category) {
                    final color = CategoryColorParser.parse(category.color);
                    final parentName = category.parentId == null
                        ? null
                        : parentNameById[category.parentId];
                    return ListTile(
                      leading: AppIcon(
                        CategoryIconMapper.fromKey(category.icon),
                        color: color,
                      ),
                      title: Text(
                        category.name,
                        style: AppTextStyles.roboto14w400,
                      ),
                      subtitle: parentName == null
                          ? null
                          : Text(
                              parentName,
                              style: AppTextStyles.roboto12w400.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                      trailing:
                          widget.controller.filterCategory?.id == category.id
                          ? const AppIcon(
                              AppHugeIcons.check,
                              color: AppColors.textPrimary,
                            )
                          : null,
                      onTap: () {
                        widget.controller.setFilterCategory(category);
                        Get.back();
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}


