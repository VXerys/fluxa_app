import 'package:get/get.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/home_summary_entity.dart';
import '../../domain/usecases/get_home_summary_usecase.dart';

class HomeController extends GetxController {
  final GetHomeSummaryUseCase getHomeSummaryUseCase;

  HomeController({required this.getHomeSummaryUseCase});

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final Rx<HomeSummaryEntity?> _summary = Rx<HomeSummaryEntity?>(null);
  HomeSummaryEntity? get summary => _summary.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    loadSummary();
  }

  Future<void> loadSummary() async {
    _isLoading.value = true;
    try {
      final result = await getHomeSummaryUseCase(const NoParams());

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          Get.snackbar('Error', failure.message);
        },
        (summary) {
          _summary.value = summary;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
