import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/voice_transaction_result_model.dart';
import 'voice_transaction_remote_datasource.dart';

class VoiceTransactionRemoteDataSourceImpl
    implements VoiceTransactionRemoteDataSource {
  final Dio _dio;

  VoiceTransactionRemoteDataSourceImpl({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConstants.fluxaAiApiBaseUrl,
              receiveTimeout: const Duration(seconds: 120),
            ),
          );

  @override
  Future<VoiceTransactionResultModel> parseVoiceTransaction(
    String audioFilePath,
  ) async {
    final String trimmedPath = audioFilePath.trim();
    if (trimmedPath.isEmpty) {
      throw ValidationException('File audio belum tersedia');
    }

    final File audioFile = File(trimmedPath);
    if (!await audioFile.exists()) {
      throw ValidationException('File audio tidak ditemukan');
    }

    if (_dio.options.baseUrl.trim().isEmpty) {
      throw ValidationException('FLUXA_AI_API_BASE_URL belum dikonfigurasi');
    }

    try {
      final FormData formData = FormData.fromMap(<String, dynamic>{
        'file': await MultipartFile.fromFile(
          trimmedPath,
          filename: trimmedPath.split(Platform.pathSeparator).last,
        ),
      });

      final Response<dynamic> response = await _dio.post<dynamic>(
        '/api/v1/voice/parse',
        data: formData,
      );
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return VoiceTransactionResultModel.fromJson(data);
      }
      if (data is Map) {
        return VoiceTransactionResultModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
      throw ServerException('Format response AI tidak valid');
    } on DioException catch (dioException) {
      throw _mapDioException(dioException);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Exception _mapDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException('Koneksi ke Voice AI gagal');
      case DioExceptionType.badResponse:
        return ServerException(_readDioMessage(dioException.response?.data));
      case DioExceptionType.cancel:
        return ServerException('Upload voice dibatalkan');
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ServerException(
          dioException.message ?? 'Voice AI gagal memproses audio',
        );
    }
  }

  String _readDioMessage(dynamic data) {
    if (data is Map) {
      final dynamic detail = data['detail'] ?? data['message'] ?? data['error'];
      if (detail != null) return detail.toString();
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return 'Voice AI gagal memproses audio';
  }
}
