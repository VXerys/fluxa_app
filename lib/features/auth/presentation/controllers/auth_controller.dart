import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';

class AuthController extends GetxController {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateUserUseCase updateUserUseCase;

  AuthController({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.updateUserUseCase,
  });

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool _isSubmitting = false.obs;
  bool get isSubmitting => _isSubmitting.value;

  final Rx<UserEntity?> _currentUser = Rx<UserEntity?>(null);
  UserEntity? get currentUser => _currentUser.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    if (_isLoading.value) return;
    _isLoading.value = true;
    try {
      final result = await getCurrentUserUseCase(const NoParams());
      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          _currentUser.value = null;
          Get.snackbar('Error', failure.message);
        },
        (user) {
          _currentUser.value = user;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    if (_isSubmitting.value) return;

    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      _setError('Email is invalid');
      return;
    }
    if (password.length < 6) {
      _setError('Password must be at least 6 characters');
      return;
    }

    _isSubmitting.value = true;
    try {
      final result = await signInUseCase(
        SignInParams(email: normalizedEmail, password: password),
      );
      result.fold(
        (failure) {
          _setError(failure.message);
        },
        (user) {
          _errorMessage.value = '';
          _currentUser.value = user;
          Get.offAllNamed(Routes.main);
        },
      );
    } finally {
      _isSubmitting.value = false;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (_isSubmitting.value) return;

    final normalizedEmail = email.trim();
    final normalizedName = displayName.trim();

    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      _setError('Email is invalid');
      return;
    }
    if (password.length < 6) {
      _setError('Password must be at least 6 characters');
      return;
    }
    if (normalizedName.isEmpty) {
      _setError('Display name is required');
      return;
    }

    _isSubmitting.value = true;
    try {
      final result = await signUpUseCase(
        SignUpParams(
          email: normalizedEmail,
          password: password,
          displayName: normalizedName,
        ),
      );
      result.fold(
        (failure) {
          _setError(failure.message);
        },
        (user) {
          _errorMessage.value = '';
          _currentUser.value = user;
          Get.offAllNamed(Routes.main);
        },
      );
    } finally {
      _isSubmitting.value = false;
    }
  }

  Future<void> signOut() async {
    if (_isSubmitting.value) return;

    _isSubmitting.value = true;
    try {
      final result = await signOutUseCase(const NoParams());
      result.fold(
        (failure) {
          _setError(failure.message);
        },
        (_) {
          _errorMessage.value = '';
          _currentUser.value = null;
          Get.offAllNamed(Routes.login);
        },
      );
    } finally {
      _isSubmitting.value = false;
    }
  }

  Future<void> updateProfile({required String displayName}) async {
    if (_isSubmitting.value) return;

    final normalizedName = displayName.trim();
    if (normalizedName.isEmpty) {
      _setError('Display name is required');
      return;
    }

    _isSubmitting.value = true;
    try {
      final result = await updateUserUseCase(
        UpdateUserParams(displayName: normalizedName),
      );
      result.fold(
        (failure) {
          _setError(failure.message);
        },
        (user) {
          _errorMessage.value = '';
          _currentUser.value = user;
          Get.snackbar('Success', 'Profile updated successfully');
        },
      );
    } finally {
      _isSubmitting.value = false;
    }
  }

  void _setError(String message) {
    _errorMessage.value = message;
    Get.snackbar('Error', message);
  }
}
