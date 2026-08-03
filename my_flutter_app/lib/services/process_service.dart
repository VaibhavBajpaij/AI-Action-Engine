import 'dart:async';

import 'package:dio/dio.dart';

import '../data/repository/content_item_repository.dart';
import '../network/api_client.dart';
import '../network/process_result.dart';
import '../network/models/result_dto.dart';
import 'device_id_service.dart';

class ProcessService {
  final ApiClient _apiClient;
  final ContentItemRepository _repository;
  final DeviceIdService _deviceIdService;
  final Duration pollInterval;

  ProcessService(
    this._apiClient,
    this._repository,
    this._deviceIdService, {
    this.pollInterval = const Duration(seconds: 2),
  });

  Stream<ProcessResult> submitUrl(String url) async* {
    yield const ProcessResult.loading();

    try {
      final deviceId = _deviceIdService.deviceId;
      final response = await _apiClient.submitProcess(url, deviceId);

      final String jobId = response['jobId'] as String;
      final bool cached = response['cached'] == true;

      if (cached) {
        yield* _fetchResult(jobId, url);
        return;
      }

      // TODO(production): Reduce to 60 (2 min) before shipping.
      // 150 attempts × 2s = 5 min, needed only for CPU-only local dev where
      // Whisper "tiny" still takes 60–120s on a laptop. Azure will be faster.
      for (int i = 0; i < 150; i++) {
        await Future.delayed(pollInterval);

        final resultResponse = await _apiClient.getResult(jobId);
        final status = resultResponse['status'] as String;

        if (status == 'done') {
          yield* _handleDoneResult(resultResponse, url);
          return;
        } else if (status == 'failed') {
          final errorString = resultResponse['error'] as String?;
          yield ProcessResult.error(_mapErrorString(errorString));
          return;
        }
      }

      yield const ProcessResult.error(ProcessError.timeout);
    } on DioException catch (e) {
      yield ProcessResult.error(_mapDioException(e));
    } catch (e) {
      yield const ProcessResult.error(ProcessError.unknown);
    }
  }

  Stream<ProcessResult> _fetchResult(String jobId, String url) async* {
    try {
      final resultResponse = await _apiClient.getResult(jobId);
      final status = resultResponse['status'] as String;

      if (status == 'done') {
        yield* _handleDoneResult(resultResponse, url);
      } else if (status == 'failed') {
        final errorString = resultResponse['error'] as String?;
        yield ProcessResult.error(_mapErrorString(errorString));
      } else {
        // Cached but somehow not done?
        yield const ProcessResult.error(ProcessError.unknown);
      }
    } on DioException catch (e) {
      yield ProcessResult.error(_mapDioException(e));
    } catch (e) {
      yield const ProcessResult.error(ProcessError.unknown);
    }
  }

  Stream<ProcessResult> _handleDoneResult(Map<String, dynamic> resultResponse, String url) async* {
    try {
      final dataJson = resultResponse['data'] as Map<String, dynamic>;
      final dto = ResultDto.fromJson(dataJson);
      await _repository.saveResultDto(dto, url);
      yield ProcessResult.success(dto);
    } catch (e, stackTrace) {
      // Log the raw response and exact exception so we can diagnose DTO parse failures.
      // ignore: avoid_print
      print('[ProcessService] _handleDoneResult FAILED');
      // ignore: avoid_print
      print('[ProcessService] Raw response: $resultResponse');
      // ignore: avoid_print
      print('[ProcessService] Exception: ${e.runtimeType}: $e');
      // ignore: avoid_print
      print('[ProcessService] StackTrace: $stackTrace');
      yield const ProcessResult.error(ProcessError.unknown);
    }
  }

  ProcessError _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return ProcessError.noInternet;
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return ProcessError.timeout;
    }

    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      if (statusCode == 429) {
        return ProcessError.quotaExceeded;
      } else if (statusCode == 400) {
        return ProcessError.unsupportedPlatform;
      } else if (statusCode != null && statusCode >= 500) {
        return ProcessError.unknown;
      }
    }

    return ProcessError.unknown;
  }

  ProcessError _mapErrorString(String? error) {
    switch (error) {
      case 'videoPrivate':
        return ProcessError.videoPrivate;
      case 'videoTooLong':
        return ProcessError.videoTooLong;
      case 'transcriptionFailed':
        return ProcessError.transcriptionFailed;
      case 'quotaExceeded':
        return ProcessError.quotaExceeded;
      case 'unsupportedPlatform':
        return ProcessError.unsupportedPlatform;
      case 'authenticationFailed':
        return ProcessError.authenticationFailed;
      default:
        return ProcessError.unknown;
    }
  }
}
