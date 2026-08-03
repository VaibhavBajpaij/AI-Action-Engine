import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'models/result_dto.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ));

  Future<Map<String, dynamic>> submitProcess(String url, String deviceId) async {
    final response = await _dio.post('/process', data: {
      'url': url,
      'deviceId': deviceId,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getResult(String jobId) async {
    final response = await _dio.get('/result/$jobId');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getQuota(String deviceId) async {
    final response = await _dio.get('/quota/$deviceId');
    return response.data as Map<String, dynamic>;
  }
}
