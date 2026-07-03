import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/sync/finance_sync_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/monthly_cashflow_comparison_entity.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/usecases/archive_wallet_usecase.dart';
import '../../domain/usecases/create_wallet_usecase.dart';
import '../../domain/usecases/get_monthly_cashflow_comparison_usecase.dart';
import '../../domain/usecases/get_total_balance_usecase.dart';
import '../../domain/usecases/get_wallets_usecase.dart';
import '../../domain/usecases/update_wallet_usecase.dart';

class WalletController extends GetxController {
  final GetWalletsUseCase getWalletsUseCase;
  final CreateWalletUseCase createWalletUseCase;
  final UpdateWalletUseCase updateWalletUseCase;
  final ArchiveWalletUseCase archiveWalletUseCase;
  final GetTotalBalanceUseCase getTotalBalanceUseCase;
  final GetMonthlyCashflowComparisonUseCase
  getMonthlyCashflowComparisonUseCase;
  final FinanceSyncService financeSyncService;

  WalletController({
    required this.getWalletsUseCase,
    required this.createWalletUseCase,
    required this.updateWalletUseCase,
    required this.archiveWalletUseCase,
    required this.getTotalBalanceUseCase,
    required this.getMonthlyCashflowComparisonUseCase,
    required this.financeSyncService,
  });

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool _isSubmitting = false.obs;
  bool get isSubmitting => _isSubmitting.value;

  bool _isCashWallet(WalletEntity wallet) {
    final nameLower = wallet.name.toLowerCase();
    return wallet.type == 'cash' ||
        nameLower.contains('tunai') ||
        nameLower.contains('cash');
  }

  final RxList<WalletEntity> _wallets = <WalletEntity>[].obs;
  List<WalletEntity> get wallets => _wallets.where(_isCashWallet).toList();

  final Rx<double> _totalBalance = 0.0.obs;
  double get totalBalance => _totalBalance.value;

  final Rx<MonthlyCashflowComparisonEntity?> _monthlyCashflowComparison =
      Rx<MonthlyCashflowComparisonEntity?>(null);
  MonthlyCashflowComparisonEntity? get monthlyCashflowComparison =>
      _monthlyCashflowComparison.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  StreamSubscription<FinanceSyncEvent>? _syncSubscription;
  int _loadRequestId = 0;

  List<WalletEntity> get cashWallets => _wallets.where(_isCashWallet).toList();
  List<WalletEntity> get bankWallets => <WalletEntity>[];
  List<WalletEntity> get ewalletWallets => <WalletEntity>[];

  @override
  void onInit() {
    super.onInit();
    _syncSubscription = financeSyncService.stream.listen(_handleSyncEvent);
    loadWallets();
  }

  Future<void> loadWallets() async {
    final requestId = ++_loadRequestId;
    _isLoading.value = true;
    try {
      await Future.wait([
        _loadWalletList(requestId),
        _loadTotalBalance(requestId),
        _loadMonthlyCashflowComparison(requestId),
      ]);
    } finally {
      if (!_isStale(requestId)) {
        _isLoading.value = false;
      }
    }
  }

  Future<void> _loadWalletList(int requestId) async {
    final result = await getWalletsUseCase(const NoParams());
    if (_isStale(requestId)) return;

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        _wallets.clear();
      },
      (data) {
        _errorMessage.value = '';
        _wallets.value = data;
        if (data.isEmpty && !_isSubmitting.value) {
          createWallet(
            name: 'Cash',
            type: 'cash',
            initialBalance: 0.0,
            currency: 'IDR',
            icon: 'wallet_01',
            silent: true,
          );
        }
      },
    );
  }

  Future<void> _loadTotalBalance(int requestId) async {
    final result = await getTotalBalanceUseCase(const NoParams());
    if (_isStale(requestId)) return;

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        _totalBalance.value = 0;
      },
      (total) {
        _totalBalance.value = total;
      },
    );
  }

  Future<void> _loadMonthlyCashflowComparison(int requestId) async {
    final result = await getMonthlyCashflowComparisonUseCase(const NoParams());
    if (_isStale(requestId)) return;

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        _monthlyCashflowComparison.value = null;
      },
      (comparison) {
        _monthlyCashflowComparison.value = comparison;
      },
    );
  }

  Future<bool> createWallet({
    required String name,
    required String type,
    required double initialBalance,
    required String currency,
    String? icon,
    String? color,
    bool silent = false,
  }) async {
    if (_isSubmitting.value) return false;

    if (name.trim().isEmpty) {
      _errorMessage.value = 'Nama dompet tidak boleh kosong';
      if (!silent) Get.snackbar('Error', _errorMessage.value);
      return false;
    }
    if (type.trim().isEmpty) {
      _errorMessage.value = 'Tipe dompet tidak boleh kosong';
      if (!silent) Get.snackbar('Error', _errorMessage.value);
      return false;
    }

    _isSubmitting.value = true;
    try {
      final result = await createWalletUseCase(
        CreateWalletParams(
          name: name.trim(),
          type: type.trim(),
          balance: initialBalance,
          currency: currency,
          icon: icon,
          color: color,
        ),
      );

      return await result.fold(
        (failure) async {
          _errorMessage.value = failure.message;
          if (!silent) Get.snackbar('Error', failure.message);
          return false;
        },
        (_) async {
          _errorMessage.value = '';
          await loadWallets();
          financeSyncService.emit(
            FinanceSyncEventType.walletMutated,
            source: 'wallet.create',
          );
          if (!silent) Get.snackbar('Sukses', 'Dompet berhasil ditambahkan');
          return true;
        },
      );
    } finally {
      _isSubmitting.value = false;
    }
  }

  Future<bool> updateWallet({
    required String id,
    String? name,
    String? icon,
    String? color,
    bool? includeInTotal,
    double? balance,
  }) async {
    if (_isSubmitting.value) return false;
    _isSubmitting.value = true;
    try {
      final result = await updateWalletUseCase(
        UpdateWalletParams(
          id: id,
          name: name?.trim(),
          icon: icon,
          color: color,
          includeInTotal: includeInTotal,
          balance: balance,
        ),
      );

      return await result.fold(
        (failure) async {
          _errorMessage.value = failure.message;
          Get.snackbar('Error', failure.message);
          return false;
        },
        (_) async {
          _errorMessage.value = '';
          await loadWallets();
          financeSyncService.emit(
            FinanceSyncEventType.walletMutated,
            source: 'wallet.update',
          );
          Get.snackbar('Sukses', 'Dompet berhasil diperbarui');
          return true;
        },
      );
    } finally {
      _isSubmitting.value = false;
    }
  }

  Future<void> archiveWallet(String id) async {
    final result = await archiveWalletUseCase(
      ArchiveWalletParams(walletId: id),
    );

    await result.fold(
      (failure) async {
        _errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (_) async {
        _errorMessage.value = '';
        await loadWallets();
        financeSyncService.emit(
          FinanceSyncEventType.walletMutated,
          source: 'wallet.archive',
        );
        Get.snackbar('Sukses', 'Dompet berhasil diarsipkan');
      },
    );
  }

  List<WalletEntity> getWalletsByType(String type) {
    return _wallets.where((wallet) => wallet.type == type).toList();
  }

  void _handleSyncEvent(FinanceSyncEvent event) {
    if (event.type == FinanceSyncEventType.walletMutated &&
        (event.source?.startsWith('wallet.') ?? false)) {
      return;
    }

    if (event.type == FinanceSyncEventType.transactionMutated ||
        event.type == FinanceSyncEventType.walletMutated ||
        event.type == FinanceSyncEventType.dataReset) {
      loadWallets();
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
