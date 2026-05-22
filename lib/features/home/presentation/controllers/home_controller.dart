import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/sync/finance_sync_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/home_summary_entity.dart';
import '../../domain/usecases/get_home_summary_usecase.dart';

class HomeController extends GetxController {
  final GetHomeSummaryUseCase getHomeSummaryUseCase;
  final FinanceSyncService financeSyncService;

  HomeController({
    required this.getHomeSummaryUseCase,
    required this.financeSyncService,
  });

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final Rx<HomeSummaryEntity?> _summary = Rx<HomeSummaryEntity?>(null);
  HomeSummaryEntity? get summary => _summary.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  StreamSubscription<FinanceSyncEvent>? _syncSubscription;
  int _loadRequestId = 0;

  @override
  void onInit() {
    super.onInit();
    _syncSubscription = financeSyncService.stream.listen(_handleSyncEvent);
    loadSummary();
  }

  Future<void> loadSummary() async {
    final requestId = ++_loadRequestId;
    _isLoading.value = true;
    try {
      final result = await getHomeSummaryUseCase(const NoParams());

      if (_isStale(requestId)) return;

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
        },
        (summary) {
          _errorMessage.value = '';
          _summary.value = summary;
        },
      );
    } finally {
      if (!_isStale(requestId)) {
        _isLoading.value = false;
      }
    }
  }

  void _handleSyncEvent(FinanceSyncEvent event) {
    if (event.type == FinanceSyncEventType.transactionMutated ||
        event.type == FinanceSyncEventType.walletMutated ||
        event.type == FinanceSyncEventType.dataReset) {
      loadSummary();
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
