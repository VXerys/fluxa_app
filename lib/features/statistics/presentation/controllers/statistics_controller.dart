import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/sync/finance_sync_service.dart';
import '../../domain/entities/statistics_summary_entity.dart';
import '../../domain/entities/top_expense_transaction_entity.dart';
import '../../domain/usecases/get_statistics_usecase.dart';
import '../../domain/repositories/statistics_repository.dart';

class StatisticsController extends GetxController {
  final GetStatisticsUseCase getStatisticsUseCase;
  final FinanceSyncService financeSyncService;

  StatisticsController({
    required this.getStatisticsUseCase,
    required this.financeSyncService,
  });

  final RxString _selectedPeriod = 'monthly'.obs;
  String get selectedPeriod => _selectedPeriod.value;

  final Rx<DateTime> _selectedDate = DateTime.now().obs;
  DateTime get selectedDate => _selectedDate.value;

  final Rx<DateTime?> _rangeStart = Rx<DateTime?>(null);
  DateTime? get rangeStart => _rangeStart.value;

  final Rx<DateTime?> _rangeEnd = Rx<DateTime?>(null);
  DateTime? get rangeEnd => _rangeEnd.value;

  final RxString _selectedType = 'expense'.obs;
  String get selectedType => _selectedType.value;

  final RxString _selectedGroupType = 'Kategori'.obs;
  String get selectedGroupType => _selectedGroupType.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  void changeGroupType(String value) {
    if (value != 'Kategori' &&
        value != 'Subkategori' &&
        value != 'Judul' &&
        value != 'Dompet') {
      return;
    }
    _selectedGroupType.value = value;
  }

  static const int maxTopTransactionsOnCard = 6;

  final Rx<StatisticsSummaryEntity?> _summary = Rx<StatisticsSummaryEntity?>(
    null,
  );
  StatisticsSummaryEntity? get summary => _summary.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  StreamSubscription<FinanceSyncEvent>? _syncSubscription;
  int _loadRequestId = 0;

  DateTime get periodStart {
    final anchor = _normalizeDate(_selectedDate.value);
    switch (_selectedPeriod.value) {
      case 'weekly':
        return anchor.subtract(Duration(days: anchor.weekday - 1));
      case 'monthly':
        return DateTime(anchor.year, anchor.month, 1);
      case 'yearly':
        return DateTime(anchor.year, 1, 1);
      case 'range':
        return _normalizeDate(_rangeStart.value ?? anchor);
      default:
        return DateTime(anchor.year, anchor.month, 1);
    }
  }

  DateTime get periodEnd {
    final anchor = _normalizeDate(_selectedDate.value);
    switch (_selectedPeriod.value) {
      case 'weekly':
        return periodStart.add(const Duration(days: 6));
      case 'monthly':
        return DateTime(anchor.year, anchor.month + 1, 0);
      case 'yearly':
        return DateTime(anchor.year, 12, 31);
      case 'range':
        return _normalizeDate(_rangeEnd.value ?? _rangeStart.value ?? anchor);
      default:
        return DateTime(anchor.year, anchor.month + 1, 0);
    }
  }

  String get periodLabel {
    final start = periodStart;
    final end = periodEnd;

    switch (_selectedPeriod.value) {
      case 'weekly':
        if (start.month == end.month && start.year == end.year) {
          return '${DateFormat('MMMM', 'id_ID').format(start)} ${start.day} - ${end.day}';
        }
        if (start.year == end.year) {
          return '${DateFormat('d MMM', 'id_ID').format(start)} - ${DateFormat('d MMM', 'id_ID').format(end)}';
        }
        return '${DateFormat('d MMM yyyy', 'id_ID').format(start)} - ${DateFormat('d MMM yyyy', 'id_ID').format(end)}';
      case 'monthly':
        return DateFormat('MMMM yyyy', 'id_ID').format(start);
      case 'yearly':
        return DateFormat('yyyy', 'id_ID').format(start);
      case 'range':
        if (start.year == end.year) {
          return '${DateFormat('d MMM', 'id_ID').format(start)} - ${DateFormat('d MMM', 'id_ID').format(end)}, ${end.year}';
        }
        return '${DateFormat('d MMM yyyy', 'id_ID').format(start)} - ${DateFormat('d MMM yyyy', 'id_ID').format(end)}';
      default:
        return DateFormat('MMMM yyyy', 'id_ID').format(start);
    }
  }

  List<TopExpenseTransactionEntity> get topTransactionsAll {
    final grouped = _summary.value?.topTransactionsByGroup;
    if (grouped == null) return const <TopExpenseTransactionEntity>[];
    return grouped[_selectedGroupType.value] ?? const <TopExpenseTransactionEntity>[];
  }

  List<TopExpenseTransactionEntity> get topTransactions {
    final items = topTransactionsAll;
    if (items.isEmpty) return const <TopExpenseTransactionEntity>[];
    return items.take(maxTopTransactionsOnCard).toList();
  }

  bool get hasMoreTopTransactions {
    return topTransactionsAll.length > maxTopTransactionsOnCard;
  }

  @override
  void onInit() {
    super.onInit();
    _syncSubscription = financeSyncService.stream.listen(_handleSyncEvent);
    loadStatistics();
  }

  void changePeriod(String period) {
    if (!_isValidPeriod(period) || _selectedPeriod.value == period) return;

    _selectedPeriod.value = period;
    if (period == 'range') {
      _rangeStart.value ??= periodStart;
      _rangeEnd.value ??= periodEnd;
    }
    loadStatistics();
  }

  void changeType(String type) {
    if (!_isValidType(type) || _selectedType.value == type) return;
    _selectedType.value = type;
    _selectedGroupType.value = 'Kategori';
    loadStatistics();
  }

  void navigatePeriod(int direction) {
    if (direction != 1 && direction != -1) return;
    if (_selectedPeriod.value == 'range') return;

    final anchor = _normalizeDate(_selectedDate.value);
    switch (_selectedPeriod.value) {
      case 'weekly':
        _selectedDate.value = anchor.add(Duration(days: 7 * direction));
        break;
      case 'monthly':
        _selectedDate.value = DateTime(anchor.year, anchor.month + direction, 1);
        break;
      case 'yearly':
        _selectedDate.value = DateTime(anchor.year + direction, 1, 1);
        break;
      default:
        _selectedDate.value = DateTime(anchor.year, anchor.month + direction, 1);
        break;
    }
    loadStatistics();
  }

  void setRange(DateTime start, DateTime end) {
    final normalizedStart = _normalizeDate(start);
    final normalizedEnd = _normalizeDate(end);

    if (normalizedStart.isAfter(normalizedEnd)) {
      _rangeStart.value = normalizedEnd;
      _rangeEnd.value = normalizedStart;
    } else {
      _rangeStart.value = normalizedStart;
      _rangeEnd.value = normalizedEnd;
    }
    _selectedPeriod.value = 'range';
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    final requestId = ++_loadRequestId;
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await getStatisticsUseCase(
      GetStatisticsParams(
        type: _selectedType.value,
        startDate: periodStart,
        endDate: _queryEndExclusive,
      ),
    );

    if (_isStale(requestId)) return;

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        _summary.value = null;
      },
      (summary) {
        _errorMessage.value = '';
        _summary.value = summary;
      },
    );

    if (_isStale(requestId)) return;
    _isLoading.value = false;
  }

  DateTime get _queryEndExclusive => periodEnd.add(const Duration(days: 1));

  void openMoreTransactions() {
    Get.toNamed(
      Routes.transactionList,
      arguments: <String, dynamic>{
        'source': 'statistics',
        'type': _selectedType.value,
        'startDate': periodStart.toIso8601String(),
        'endDateExclusive': _queryEndExclusive.toIso8601String(),
      },
    );
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isValidPeriod(String value) {
    return value == 'weekly' ||
        value == 'monthly' ||
        value == 'yearly' ||
        value == 'range';
  }

  bool _isValidType(String value) {
    return value == 'income' || value == 'expense';
  }

  void _handleSyncEvent(FinanceSyncEvent event) {
    if (event.type == FinanceSyncEventType.transactionMutated ||
        event.type == FinanceSyncEventType.dataReset) {
      loadStatistics();
    }
  }

  bool _isStale(int requestId) {
    return requestId != _loadRequestId || isClosed;
  }

  @override
  void onClose() {
    _syncSubscription?.cancel();
    super.onClose();
  }
}
