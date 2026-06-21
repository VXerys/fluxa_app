import 'dart:async';
import 'dart:math' as math;

import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../transaction/domain/entities/category_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../transaction/domain/usecases/add_transaction_usecase.dart';
import '../../../transaction/domain/usecases/get_categories_usecase.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/domain/usecases/get_wallets_usecase.dart';
import '../../domain/entities/voice_transaction_draft_params.dart';
import '../../domain/entities/voice_transaction_result_entity.dart';
import '../../domain/usecases/cancel_voice_recording_usecase.dart';
import '../../domain/usecases/dispose_voice_recorder_usecase.dart';
import '../../domain/usecases/get_voice_recording_amplitude_usecase.dart';
import '../../domain/usecases/parse_voice_transaction_usecase.dart';
import '../../domain/usecases/start_voice_recording_usecase.dart';
import '../../domain/usecases/stop_voice_recording_usecase.dart';
import '../services/voice_recording_feedback_service.dart';

enum VoiceTransactionState {
  idle,
  recording,
  uploading,
  processing,
  success,
  failure,
}

class VoiceTransactionController extends GetxController {
  final StartVoiceRecordingUseCase startVoiceRecordingUseCase;
  final StopVoiceRecordingUseCase stopVoiceRecordingUseCase;
  final CancelVoiceRecordingUseCase cancelVoiceRecordingUseCase;
  final ParseVoiceTransactionUseCase parseVoiceTransactionUseCase;
  final DisposeVoiceRecorderUseCase disposeVoiceRecorderUseCase;
  final GetVoiceRecordingAmplitudeUseCase getVoiceRecordingAmplitudeUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetWalletsUseCase getWalletsUseCase;
  final AddTransactionUseCase addTransactionUseCase;
  final VoiceRecordingFeedbackService feedbackService;

  VoiceTransactionController({
    required this.startVoiceRecordingUseCase,
    required this.stopVoiceRecordingUseCase,
    required this.cancelVoiceRecordingUseCase,
    required this.parseVoiceTransactionUseCase,
    required this.disposeVoiceRecorderUseCase,
    required this.getVoiceRecordingAmplitudeUseCase,
    required this.getCategoriesUseCase,
    required this.getWalletsUseCase,
    required this.addTransactionUseCase,
    required this.feedbackService,
  });

  static const int minRecordingDurationMs = 1200;
  static const int initialNoSpeechTimeoutMs = 5500;
  static const int thinkingGraceBeforeSpeechMs = 5500;
  static const int silenceAfterSpeechTimeoutMs = 2000;
  static const int longPauseGraceMs = 3500;
  static const int maxRecordingDurationMs = 12000;
  static const int amplitudePollIntervalMs = 150;
  static const int speechHitRequiredSamples = 2;
  static const int silenceHitRequiredMs = 2000;
  static const int noiseFloorCalibrationMs = 750;
  static const double fallbackNoiseFloorDb = -60;
  static const double invalidAmplitudeFloorDb = -120;
  static const double calibrationMaxNoiseSampleDb = -35;

  final Rx<VoiceTransactionState> _state = VoiceTransactionState.idle.obs;
  VoiceTransactionState get state => _state.value;

  final Rx<VoiceTransactionResultEntity?> _result =
      Rx<VoiceTransactionResultEntity?>(null);
  VoiceTransactionResultEntity? get result => _result.value;

  final Rx<VoiceTransactionDraftParams?> _draft =
      Rx<VoiceTransactionDraftParams?>(null);
  VoiceTransactionDraftParams? get draft => _draft.value;

  final RxString _failureMessage = ''.obs;
  String get failureMessage => _failureMessage.value;

  final RxString _lastAudioPath = ''.obs;
  String get lastAudioPath => _lastAudioPath.value;

  final RxInt _recordingElapsedMs = 0.obs;
  int get recordingElapsedMs => _recordingElapsedMs.value;

  final RxBool _hasDetectedSpeech = false.obs;
  bool get hasDetectedSpeech => _hasDetectedSpeech.value;

  final RxBool _showContinuingHint = false.obs;
  bool get showContinuingHint => _showContinuingHint.value;

  final RxBool _isSavingDraft = false.obs;
  bool get isSavingDraft => _isSavingDraft.value;

  Timer? _amplitudeTimer;
  DateTime? _recordingStartedAt;
  DateTime? _lastSpeechAt;
  bool _isEvaluatingRecording = false;
  bool _isStopping = false;
  int _consecutiveSpeechHits = 0;
  int _consecutiveSilenceMs = 0;
  double? _noiseFloorDb;
  double _noiseFloorTotalDb = 0;
  int _noiseFloorSampleCount = 0;

  bool get isBusy =>
      state == VoiceTransactionState.uploading ||
      state == VoiceTransactionState.processing;

  bool get isDraftComplete => _getMissingDraftFields(_draft.value).isEmpty;

  List<String> get missingDraftFields => _getMissingDraftFields(_draft.value);

  Future<void> startRecording() async {
    if (isBusy || state == VoiceTransactionState.recording) return;

    _failureMessage.value = '';
    _result.value = null;
    _draft.value = null;
    _lastAudioPath.value = '';
    final result = await startVoiceRecordingUseCase(const NoParams());
    result.fold(
      (failure) {
        unawaited(feedbackService.playError());
        _setFailure(failure.message, playFeedback: false);
      },
      (_) {
        _state.value = VoiceTransactionState.recording;
        _startRecordingMonitoring();
        unawaited(feedbackService.playStart());
      },
    );
  }

  Future<void> stopRecordingAndParse() async {
    if (state != VoiceTransactionState.recording) return;
    await _stopRecordingAndParse();
  }

  Future<void> _stopRecordingAndParse() async {
    if (_isStopping) return;
    _isStopping = true;
    _failureMessage.value = '';
    _stopRecordingMonitoring();
    _state.value = VoiceTransactionState.processing;

    final stopResult = await stopVoiceRecordingUseCase(const NoParams());
    await stopResult.fold(
      (failure) async {
        _isStopping = false;
        _setFailure(failure.message);
      },
      (audioPath) async {
        unawaited(feedbackService.playStop());
        _lastAudioPath.value = audioPath;
        await _parseAudioPath(audioPath);
      },
    );
    _isStopping = false;
  }

  Future<void> cancelRecording() async {
    if (isBusy || state != VoiceTransactionState.recording) return;

    _stopRecordingMonitoring();
    _isStopping = false;
    final result = await cancelVoiceRecordingUseCase(const NoParams());
    result.fold(
      (failure) => _setFailure(failure.message),
      (_) {
        unawaited(feedbackService.playCancel());
        _clearDraftState();
      },
    );
  }

  Future<void> retryParse() async {
    if (isBusy) return;
    final String audioPath = _lastAudioPath.value.trim();
    if (audioPath.isEmpty) {
      _setFailure('File audio belum tersedia untuk dicoba ulang');
      return;
    }
    await _parseAudioPath(audioPath);
  }

  void resetDraft() {
    if (isBusy || _isSavingDraft.value) return;
    _clearDraftState();
  }

  Future<void> saveDraftAsTransaction() async {
    if (_isSavingDraft.value) return;

    final VoiceTransactionDraftParams? resolvedDraft = await _ensureDraft();
    if (resolvedDraft == null) {
      Get.snackbar('Draft belum siap', 'Coba proses ulang rekaman suara.');
      return;
    }

    if (!isDraftComplete) {
      await openAddTransactionWithDraft();
      return;
    }

    final String? type = _sanitizeType(resolvedDraft.type);
    final double? amount = resolvedDraft.amount;
    final String? walletId = _normalizedOrNull(resolvedDraft.walletId);
    final String? categoryId = _normalizedOrNull(
      resolvedDraft.resolvedTransactionCategoryId,
    );

    if (type == null ||
        amount == null ||
        walletId == null ||
        categoryId == null) {
      await openAddTransactionWithDraft();
      return;
    }

    _isSavingDraft.value = true;
    try {
      final result = await addTransactionUseCase(
        AddTransactionParams(
          type: type,
          amount: amount,
          categoryId: categoryId,
          walletId: walletId,
          note: resolvedDraft.combinedNote,
          date: resolvedDraft.occurredAt,
          time: resolvedDraft.timeString,
        ),
      );

      result.fold(
        (failure) {
          Get.snackbar('Gagal menyimpan', failure.message);
        },
        (_) {
          Get.snackbar('Sukses', 'Transaksi berhasil disimpan');
          _clearDraftState();
          Get.offNamed(Routes.transactionList);
        },
      );
    } finally {
      _isSavingDraft.value = false;
    }
  }

  Future<void> editDraft() async {
    await openAddTransactionWithDraft();
  }

  Future<void> openAddTransactionWithDraft() async {
    final VoiceTransactionDraftParams? resolvedDraft = await _ensureDraft();
    if (resolvedDraft == null) {
      Get.snackbar('Draft belum siap', 'Coba proses ulang rekaman suara.');
      return;
    }

    final dynamic saveResult = await Get.toNamed(
      Routes.addTransaction,
      arguments: resolvedDraft,
    );

    if (saveResult == true) {
      resetDraft();
      Get.offNamed(Routes.transactionList);
    }
  }

  Future<void> _parseAudioPath(String audioPath) async {
    _draft.value = null;
    _state.value = VoiceTransactionState.uploading;
    final resultFuture = parseVoiceTransactionUseCase(
      ParseVoiceTransactionParams(audioFilePath: audioPath),
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (_state.value == VoiceTransactionState.uploading) {
      _state.value = VoiceTransactionState.processing;
    }
    final result = await resultFuture;
    await result.fold(
      (failure) async => _setFailure(failure.message),
      (voiceResult) async {
        _result.value = voiceResult;
        _draft.value = await _resolveDraftFromResult(voiceResult);
        _failureMessage.value = '';
        _state.value = VoiceTransactionState.success;
      },
    );
  }

  void _startRecordingMonitoring() {
    _stopRecordingMonitoring();
    _recordingStartedAt = DateTime.now();
    _lastSpeechAt = null;
    _recordingElapsedMs.value = 0;
    _hasDetectedSpeech.value = false;
    _showContinuingHint.value = false;
    _isStopping = false;
    _consecutiveSpeechHits = 0;
    _consecutiveSilenceMs = 0;
    _noiseFloorDb = null;
    _noiseFloorTotalDb = 0;
    _noiseFloorSampleCount = 0;
    _amplitudeTimer = Timer.periodic(
      const Duration(milliseconds: amplitudePollIntervalMs),
      (_) => unawaited(_evaluateRecordingAmplitude()),
    );
  }

  void _stopRecordingMonitoring() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    _isEvaluatingRecording = false;
  }

  Future<void> _evaluateRecordingAmplitude() async {
    if (_isEvaluatingRecording || state != VoiceTransactionState.recording) {
      return;
    }

    final DateTime? startedAt = _recordingStartedAt;
    if (startedAt == null) return;

    _isEvaluatingRecording = true;
    try {
      final int elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;
      _recordingElapsedMs.value = elapsedMs;

      final amplitudeResult = await getVoiceRecordingAmplitudeUseCase(
        const NoParams(),
      );
      final double? amplitudeDb = amplitudeResult.fold(
        (_) => null,
        (value) => value,
      );
      final bool hasUsableAmplitude =
          amplitudeDb != null && amplitudeDb > invalidAmplitudeFloorDb;

      if (hasUsableAmplitude &&
          elapsedMs <= noiseFloorCalibrationMs &&
          amplitudeDb <= calibrationMaxNoiseSampleDb) {
        _noiseFloorTotalDb += amplitudeDb;
        _noiseFloorSampleCount += 1;
        _noiseFloorDb = _noiseFloorTotalDb / _noiseFloorSampleCount;
      }

      final double effectiveNoiseFloorDb =
          _noiseFloorDb ?? fallbackNoiseFloorDb;
      final double speechThresholdDb = math.max(
        effectiveNoiseFloorDb + 10,
        -45,
      );
      final bool isSpeechSample =
          hasUsableAmplitude && amplitudeDb >= speechThresholdDb;

      if (isSpeechSample) {
        _consecutiveSpeechHits += 1;
        _consecutiveSilenceMs = 0;
        _showContinuingHint.value = false;

        if (_consecutiveSpeechHits >= speechHitRequiredSamples) {
          _hasDetectedSpeech.value = true;
          _lastSpeechAt = DateTime.now();
        }
      } else {
        _consecutiveSpeechHits = 0;
        if (_hasDetectedSpeech.value) {
          _consecutiveSilenceMs += amplitudePollIntervalMs;
          _showContinuingHint.value = _consecutiveSilenceMs >= 600;
        }
      }

      if (state != VoiceTransactionState.recording) return;

      if (elapsedMs >= maxRecordingDurationMs) {
        await _stopRecordingAndParse();
        return;
      }

      if (elapsedMs < minRecordingDurationMs) return;

      if (!_hasDetectedSpeech.value &&
          elapsedMs >=
              math.max(initialNoSpeechTimeoutMs, thinkingGraceBeforeSpeechMs)) {
        await _cancelNoSpeechRecording();
        return;
      }

      final int requiredSilenceMs = math.min(
        longPauseGraceMs,
        math.max(silenceAfterSpeechTimeoutMs, silenceHitRequiredMs),
      );
      final DateTime? lastSpeechAt = _lastSpeechAt;
      final int silenceSinceLastSpeechMs = lastSpeechAt == null
          ? 0
          : DateTime.now().difference(lastSpeechAt).inMilliseconds;
      if (_hasDetectedSpeech.value &&
          _consecutiveSilenceMs >= requiredSilenceMs &&
          silenceSinceLastSpeechMs >= requiredSilenceMs) {
        await _stopRecordingAndParse();
      }
    } finally {
      _isEvaluatingRecording = false;
    }
  }

  Future<void> _cancelNoSpeechRecording() async {
    _stopRecordingMonitoring();
    _isStopping = false;
    final result = await cancelVoiceRecordingUseCase(const NoParams());
    result.fold(
      (failure) => _setFailure(failure.message),
      (_) => _setFailure(
        'Suara belum terdengar. Coba rekam ulang lebih dekat ke mikrofon.',
      ),
    );
  }

  void _setFailure(String message, {bool playFeedback = true}) {
    _stopRecordingMonitoring();
    _isStopping = false;
    if (playFeedback) {
      unawaited(feedbackService.playError());
    }
    _failureMessage.value = message;
    _draft.value = null;
    _state.value = VoiceTransactionState.failure;
  }

  Future<VoiceTransactionDraftParams?> _ensureDraft() async {
    final VoiceTransactionDraftParams? existingDraft = _draft.value;
    if (existingDraft != null) {
      return existingDraft;
    }

    final VoiceTransactionResultEntity? currentResult = _result.value;
    if (currentResult == null) {
      return null;
    }

    final VoiceTransactionDraftParams resolvedDraft =
        await _resolveDraftFromResult(currentResult);
    _draft.value = resolvedDraft;
    return resolvedDraft;
  }

  Future<VoiceTransactionDraftParams> _resolveDraftFromResult(
    VoiceTransactionResultEntity voiceResult,
  ) async {
    final String? type = _sanitizeType(
      voiceResult.transaction.type,
      voiceResult.classification.resolvedType,
      voiceResult.classification.rawType,
    );
    final double? amount = voiceResult.transaction.amount > 0
        ? voiceResult.transaction.amount
        : null;
    final String categoryHint = _firstNonEmpty(
      <String?>[
        voiceResult.classification.category,
        voiceResult.transaction.category,
      ],
    );
    final String? walletHint = _normalizedOrNull(voiceResult.transaction.wallet);

    final List<CategoryEntity> categories = await _loadCategories(type);
    final List<WalletEntity> wallets = await _loadWallets();

    final _ResolvedCategory? resolvedCategory = _resolveCategory(
      type: type,
      categoryHint: categoryHint,
      categories: categories,
    );
    final WalletEntity? resolvedWallet = _resolveWallet(
      walletHint: walletHint,
      wallets: wallets,
    );

    final String fallbackCategoryTitle =
        resolvedCategory?.child?.name ??
        resolvedCategory?.parent.name ??
        _normalizedOrNull(categoryHint) ??
        '';
    final String derivedTitle = _deriveDraftTitle(
      title: _normalizedOrNull(voiceResult.transaction.title),
      description: _normalizedOrNull(voiceResult.transaction.description),
      normalizedTranscript: _normalizedOrNull(
        voiceResult.transcript.normalized,
      ),
      rawTranscript: _normalizedOrNull(voiceResult.transcript.raw),
      fallbackCategory: fallbackCategoryTitle,
    );

    return VoiceTransactionDraftParams(
      title: derivedTitle,
      type: type,
      amount: amount,
      categoryName: resolvedCategory?.parent.name ?? _normalizedOrNull(categoryHint),
      categoryId: resolvedCategory?.parent.id,
      subcategoryName: resolvedCategory?.child?.name,
      subcategoryId: resolvedCategory?.child?.id,
      walletName: resolvedWallet?.name ?? walletHint,
      walletId: resolvedWallet?.id,
      description: _normalizedOrNull(voiceResult.transaction.description),
      currency: _normalizedOrNull(voiceResult.transaction.currency) ?? 'IDR',
      transcriptRaw: voiceResult.transcript.raw,
      transcriptNormalized: voiceResult.transcript.normalized,
      occurredAt: DateTime.now(),
    );
  }

  Future<List<CategoryEntity>> _loadCategories(String? type) async {
    if (type == null) return <CategoryEntity>[];
    final result = await getCategoriesUseCase(GetCategoriesParams(type: type));
    List<CategoryEntity> categories = <CategoryEntity>[];
    result.fold((_) {}, (data) => categories = data);
    return categories;
  }

  Future<List<WalletEntity>> _loadWallets() async {
    final result = await getWalletsUseCase(const NoParams());
    List<WalletEntity> wallets = <WalletEntity>[];
    result.fold((_) {}, (data) => wallets = data);
    return wallets;
  }

  _ResolvedCategory? _resolveCategory({
    required String? type,
    required String categoryHint,
    required List<CategoryEntity> categories,
  }) {
    final String normalizedHint = _normalizeLookup(categoryHint);
    if (type == null || normalizedHint.isEmpty || categories.isEmpty) {
      return null;
    }

    final List<CategoryEntity> typedCategories = categories
        .where((category) => category.type == type)
        .toList();
    if (typedCategories.isEmpty) return null;

    final List<CategoryEntity> parentCategories = typedCategories
        .where((category) => category.parentId == null)
        .toList();
    final List<CategoryEntity> childCategories = typedCategories
        .where((category) => category.parentId != null)
        .toList();

    final CategoryEntity? exactChild = _pickBestCategoryMatch(
      childCategories,
      normalizedHint,
      exactOnly: true,
    );
    if (exactChild != null) {
      final CategoryEntity? parent = parentCategories.firstWhereOrNull(
        (category) => category.id == exactChild.parentId,
      );
      return _ResolvedCategory(parent: parent ?? exactChild, child: parent == null ? null : exactChild);
    }

    final CategoryEntity? exactParent = _pickBestCategoryMatch(
      parentCategories,
      normalizedHint,
      exactOnly: true,
    );
    if (exactParent != null) {
      return _ResolvedCategory(parent: exactParent);
    }

    final CategoryEntity? partialChild = _pickBestCategoryMatch(
      childCategories,
      normalizedHint,
    );
    if (partialChild != null) {
      final CategoryEntity? parent = parentCategories.firstWhereOrNull(
        (category) => category.id == partialChild.parentId,
      );
      return _ResolvedCategory(parent: parent ?? partialChild, child: parent == null ? null : partialChild);
    }

    final CategoryEntity? partialParent = _pickBestCategoryMatch(
      parentCategories,
      normalizedHint,
    );
    if (partialParent != null) {
      return _ResolvedCategory(parent: partialParent);
    }

    return null;
  }

  CategoryEntity? _pickBestCategoryMatch(
    List<CategoryEntity> candidates,
    String normalizedHint, {
    bool exactOnly = false,
  }) {
    CategoryEntity? bestMatch;
    int bestScore = 0;

    for (final CategoryEntity candidate in candidates) {
      final int score = _matchScore(
        candidate.name,
        normalizedHint,
        exactOnly: exactOnly,
      );
      if (score > bestScore) {
        bestScore = score;
        bestMatch = candidate;
      }
    }

    return bestMatch;
  }

  WalletEntity? _resolveWallet({
    required String? walletHint,
    required List<WalletEntity> wallets,
  }) {
    if (wallets.isEmpty) return null;

    if (walletHint == null) {
      return _pickDefaultWallet(wallets);
    }

    final String normalizedHint = _normalizeLookup(walletHint);
    if (normalizedHint.isEmpty) {
      return _pickDefaultWallet(wallets);
    }

    WalletEntity? bestMatch;
    int bestScore = 0;
    for (final WalletEntity wallet in wallets) {
      final int score = _matchScore(wallet.name, normalizedHint);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = wallet;
      }
    }

    return bestScore > 0 ? bestMatch : null;
  }

  WalletEntity? _pickDefaultWallet(List<WalletEntity> wallets) {
    if (wallets.isEmpty) return null;
    return wallets.firstWhereOrNull((wallet) => wallet.includeInTotal) ??
        wallets.first;
  }

  List<String> _getMissingDraftFields(VoiceTransactionDraftParams? draft) {
    if (draft == null) return <String>[];

    final List<String> missingFields = <String>[];
    if (!draft.hasMeaningfulTitle) {
      missingFields.add('Judul');
    }
    if (_sanitizeType(draft.type) == null) {
      missingFields.add('Jenis transaksi');
    }
    if (draft.amount == null || draft.amount! <= 0) {
      missingFields.add('Nominal');
    }
    if (_normalizedOrNull(draft.resolvedTransactionCategoryId) == null) {
      missingFields.add('Kategori');
    }
    if (_normalizedOrNull(draft.walletId) == null) {
      missingFields.add('Dompet');
    }
    return missingFields;
  }

  String _deriveDraftTitle({
    required String? title,
    required String? description,
    required String? normalizedTranscript,
    required String? rawTranscript,
    required String fallbackCategory,
  }) {
    final String source = _firstNonEmpty(<String?>[
      title,
      description,
      normalizedTranscript,
      rawTranscript,
    ]);

    final String cleanedTitle = _cleanTitleCandidate(source);
    if (cleanedTitle.isNotEmpty) {
      return cleanedTitle;
    }

    final String normalizedCategory = _toSentenceCase(fallbackCategory);
    if (normalizedCategory.isNotEmpty) {
      return normalizedCategory;
    }

    return 'Transaksi suara';
  }

  String _cleanTitleCandidate(String source) {
    String normalized = source.toLowerCase().trim();
    if (normalized.isEmpty) return '';

    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    normalized = normalized.replaceAllMapped(
      RegExp(r'\b(go\s*pay|top\s*up)\b'),
      (match) => match.group(0)?.replaceAll(RegExp(r'\s+'), '') ?? '',
    );

    final List<String> amountTokens = <String>[
      'rp',
      'idr',
      'rebu',
      'ribu',
      'rb',
      'ratus',
      'puluh',
      'belas',
      'juta',
      'miliar',
      'triliun',
      'perak',
      'sen',
      'nol',
      'satu',
      'dua',
      'tiga',
      'empat',
      'lima',
      'enam',
      'tujuh',
      'delapan',
      'sembilan',
      'sepuluh',
      'sebelas',
      'seratus',
      'seribu',
      'sejuta',
    ];
    final List<String> connectorTokens = <String>[
      'dengan',
      'pakai',
      'pake',
      'via',
      'dari',
      'di',
    ];
    final List<String> walletTokens = <String>[
      'bca',
      'dana',
      'gopay',
      'gopaylater',
      'ovo',
      'cash',
      'tunai',
      'mandiri',
      'bri',
      'bni',
      'seabank',
    ];
    final List<String> removableLeadingVerbs = <String>[
      'beli',
      'bayar',
      'mayar',
      'jajan',
      'transfer',
      'topup',
    ];

    final List<String> sourceTokens = normalized
        .split(RegExp(r'\s+'))
        .where((token) => token.trim().isNotEmpty)
        .toList();
    final List<String> filteredTokens = <String>[];

    for (final String token in sourceTokens) {
      if (RegExp(r'^\d+([.,]\d+)?$').hasMatch(token)) {
        continue;
      }
      if (amountTokens.contains(token)) {
        continue;
      }
      if (connectorTokens.contains(token)) {
        continue;
      }
      if (walletTokens.contains(token)) {
        continue;
      }
      filteredTokens.add(token);
    }

    while (filteredTokens.isNotEmpty &&
        removableLeadingVerbs.contains(filteredTokens.first) &&
        filteredTokens.length > 1) {
      filteredTokens.removeAt(0);
    }

    final String cleaned = filteredTokens.join(' ').replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    return _toSentenceCase(cleaned);
  }

  String _toSentenceCase(String value) {
    final String trimmed = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) return '';

    final String lower = trimmed.toLowerCase();
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }

  void _clearDraftState() {
    _failureMessage.value = '';
    _result.value = null;
    _draft.value = null;
    _lastAudioPath.value = '';
    _recordingElapsedMs.value = 0;
    _hasDetectedSpeech.value = false;
    _showContinuingHint.value = false;
    _isStopping = false;
    _consecutiveSpeechHits = 0;
    _consecutiveSilenceMs = 0;
    _noiseFloorDb = null;
    _noiseFloorTotalDb = 0;
    _noiseFloorSampleCount = 0;
    _state.value = VoiceTransactionState.idle;
  }

  String? _sanitizeType(String? primary, [String? secondary, String? tertiary]) {
    for (final String? candidate in <String?>[primary, secondary, tertiary]) {
      final String? normalized = _normalizedOrNull(candidate)?.toLowerCase();
      if (normalized == 'income' || normalized == 'expense') {
        return normalized;
      }
      if (normalized == 'transfer') {
        return 'expense';
      }
    }
    return null;
  }

  String _firstNonEmpty(List<String?> values) {
    for (final String? value in values) {
      final String? normalized = _normalizedOrNull(value);
      if (normalized != null) {
        return normalized;
      }
    }
    return '';
  }

  String? _normalizedOrNull(String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _normalizeLookup(String? value) {
    final String normalized = (value ?? '').toLowerCase().trim();
    return normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  int _matchScore(
    String candidateName,
    String normalizedHint, {
    bool exactOnly = false,
  }) {
    final String normalizedCandidate = _normalizeLookup(candidateName);
    if (normalizedCandidate.isEmpty || normalizedHint.isEmpty) {
      return 0;
    }
    if (normalizedCandidate == normalizedHint) {
      return 400;
    }
    if (exactOnly) return 0;
    if (normalizedCandidate.startsWith(normalizedHint) ||
        normalizedHint.startsWith(normalizedCandidate)) {
      return 260;
    }
    if (normalizedCandidate.contains(normalizedHint) ||
        normalizedHint.contains(normalizedCandidate)) {
      return 180;
    }
    return 0;
  }

  @override
  void onClose() {
    _stopRecordingMonitoring();
    unawaited(disposeVoiceRecorderUseCase(const NoParams()));
    super.onClose();
  }
}

class _ResolvedCategory {
  final CategoryEntity parent;
  final CategoryEntity? child;

  const _ResolvedCategory({
    required this.parent,
    this.child,
  });
}
