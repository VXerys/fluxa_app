import 'package:get/get.dart';
import 'package:fluxa_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fluxa_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fluxa_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fluxa_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:fluxa_app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:fluxa_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:fluxa_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:fluxa_app/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:fluxa_app/features/auth/presentation/controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Global singletons for Auth
    Get.put<AuthRemoteDataSource>(AuthRemoteDataSourceImpl(), permanent: true);
    Get.put<AuthRepository>(
      AuthRepositoryImpl(remoteDataSource: Get.find()),
      permanent: true,
    );

    Get.put(SignUpUseCase(repository: Get.find()), permanent: true);
    Get.put(SignInUseCase(repository: Get.find()), permanent: true);
    Get.put(SignOutUseCase(repository: Get.find()), permanent: true);
    Get.put(GetCurrentUserUseCase(repository: Get.find()), permanent: true);
    Get.put(UpdateUserUseCase(Get.find()), permanent: true);

    Get.put(
      AuthController(
        signUpUseCase: Get.find(),
        signInUseCase: Get.find(),
        signOutUseCase: Get.find(),
        getCurrentUserUseCase: Get.find(),
        updateUserUseCase: Get.find(),
      ),
      permanent: true,
    );
  }
}
