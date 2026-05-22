import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/sync/finance_sync_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/usecases/archive_wallet_usecase.dart';
import '../../domain/usecases/create_wallet_usecase.dart';
import '../../domain/usecases/get_total_balance_usecase.dart';
import '../../domain/usecases/get_wallets_usecase.dart';
import '../../domain/usecases/update_wallet_usecase.dart';

class WalletController extends GetxController {
  final GetWalletsUseCase getWalletsUseCase;
  final CreateWalletUseCase createWalletUseCase;
  final UpdateWalletUseCase updateWalletUseCase;
  final ArchiveWalletUseCase archiveWalletUseCase;
  final GetTotalBalanceUseCase getTotalBalanceUseCase;
  final FinanceSyncService financeSyncService;

  WalletController({
    required this.getWalletsUseCase,
    required this.createWalletUseCase,
    required this.updateWalletUseCase,
    required this.archiveWalletUseCase,
    required this.getTotalBalanceUseCase,
    required this.financeSyncService,
  });

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool _isSubmitting = false.obs;
  bool get isSubmitting => _isSubmitting.value;

  final RxList<WalletEntity> _wallets = <WalletEntity>[].obs;
  List<WalletEntity> get wallets => _wallets;

  final Rx<double> _totalBalance = 0.0.obs;
  double get totalBalance => _totalBalance.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  StreamSubscription<FinanceSyncEvent>? _syncSubscription;
  int _loadRequestId = 0;

  List<WalletEntity> get cashWallets => getWalletsByType('cash');
  List<WalletEntity> get bankWallets => getWalletsByType('bank');
  List<WalletEntity> get ewalletWallets => getWalletsByType('ewallet');

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

  Future<bool> createWallet({
    required String name,
    required String type,
    required double initialBalance,
    required String currency,
    String? icon,
    String? color,
  }) async {
    if (_isSubmitting.value) return false;

    if (name.trim().isEmpty) {
      _errorMessage.value = 'Nama dompet tidak boleh kosong';
      Get.snackbar('Error', _errorMessage.value);
      return false;
    }
    if (type.trim().isEmpty) {
      _errorMessage.value = 'Tipe dompet tidak boleh kosong';
      Get.snackbar('Error', _errorMessage.value);
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
          Get.snackbar('Error', failure.message);
          return false;
        },
        (_) async {
          _errorMessage.value = '';
          await loadWallets();
          financeSyncService.emit(
            FinanceSyncEventType.walletMutated,
            source: 'wallet.create',
          );
          Get.snackbar('Sukses', 'Dompet berhasil ditambahkan');
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
