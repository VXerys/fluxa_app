import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/storage_service.dart';
import 'onboarding/onboarding_slide1_widget.dart';
import 'onboarding/onboarding_slide2_widget.dart';
import 'onboarding/onboarding_slide3_widget.dart';
import 'onboarding/onboarding_slide4_widget.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    final int currentPage = _pageController.page?.round() ?? 0;
    if (currentPage >= 3) {
      await _completeOnboarding();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _skipOnboarding() async {
    await _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await StorageService.write('has_seen_onboarding', true);
    if (!mounted) {
      return;
    }
    Get.offAllNamed(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: 4,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          switch (index) {
            case 0:
              return OnboardingSlide1Widget(
                onNext: _nextPage,
                onSkip: _skipOnboarding,
              );
            case 1:
              return OnboardingSlide2Widget(onNext: _nextPage);
            case 2:
              return OnboardingSlide3Widget(onNext: _nextPage);
            default:
              return OnboardingSlide4Widget(onGetStarted: _completeOnboarding);
          }
        },
      ),
    );
  }
}
