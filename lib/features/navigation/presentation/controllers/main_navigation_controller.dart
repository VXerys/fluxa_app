import 'package:get/get.dart';

class MainNavigationController extends GetxController {
  final RxInt _currentIndex = 0.obs;

  int get currentIndex => _currentIndex.value;

  int get stackIndex => currentIndex == 3 ? 1 : 0;

  void changeTab(int index) {
    if (index == 1 || index == 2) {
      return;
    }

    _currentIndex.value = index;
  }
}
