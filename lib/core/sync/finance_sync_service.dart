import 'dart:async';

enum FinanceSyncEventType {
  transactionMutated,
  walletMutated,
  dataReset,
}

class FinanceSyncEvent {
  final FinanceSyncEventType type;
  final String? source;
  final DateTime emittedAt;

  const FinanceSyncEvent({
    required this.type,
    this.source,
    required this.emittedAt,
  });
}

class FinanceSyncService {
  final StreamController<FinanceSyncEvent> _controller =
      StreamController<FinanceSyncEvent>.broadcast();

  Stream<FinanceSyncEvent> get stream => _controller.stream;

  void emit(FinanceSyncEventType type, {String? source}) {
    _controller.add(
      FinanceSyncEvent(
        type: type,
        source: source,
        emittedAt: DateTime.now(),
      ),
    );
  }

  void dispose() {
    _controller.close();
  }
}
