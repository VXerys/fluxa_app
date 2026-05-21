import 'package:get/get.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());

    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: Get.find()),
    );

    Get.lazyPut(() => SignUpUseCase(repository: Get.find()));
    Get.lazyPut(() => SignInUseCase(repository: Get.find()));
    Get.lazyPut(() => SignOutUseCase(repository: Get.find()));
    Get.lazyPut(() => GetCurrentUserUseCase(repository: Get.find()));
    Get.lazyPut(() => UpdateUserUseCase(Get.find()));

    Get.lazyPut(
      () => AuthController(
        signUpUseCase: Get.find(),
        signInUseCase: Get.find(),
        signOutUseCase: Get.find(),
        getCurrentUserUseCase: Get.find(),
        updateUserUseCase: Get.find(),
      ),
    );
  }
}
