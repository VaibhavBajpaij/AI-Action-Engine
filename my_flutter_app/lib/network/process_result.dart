import 'package:freezed_annotation/freezed_annotation.dart';
import 'models/result_dto.dart';

part 'process_result.freezed.dart';

@freezed
sealed class ProcessResult with _$ProcessResult {
  const factory ProcessResult.loading() = _Loading;
  const factory ProcessResult.success(ResultDto data) = _Success;
  const factory ProcessResult.error(ProcessError error) = _Error;
}

enum ProcessError {
  noInternet,
  quotaExceeded,
  videoPrivate,
  videoTooLong,
  transcriptionFailed,
  unsupportedPlatform,
  timeout,
  authenticationFailed,
  unknown
}

extension ProcessErrorExtension on ProcessError {
  String userMessage([String? platform]) {
    switch (this) {
      case ProcessError.videoPrivate:
        if (platform == 'linkedin' || platform == 'facebook') {
          return "This ${platform == 'linkedin' ? 'LinkedIn' : 'Facebook'} post requires login to view and can't be accessed.";
        }
        return "This video is private or restricted.";
      case ProcessError.videoTooLong:
        return "Videos longer than 3 minutes aren't supported yet.";
      case ProcessError.quotaExceeded:
        return "You've used your 3 free Instagram and LinkedIn generations today.";
      case ProcessError.noInternet:
        return "No internet connection available.";
      case ProcessError.transcriptionFailed:
        return "There wasn't enough speech or text in this one to work with.";
      case ProcessError.unsupportedPlatform:
        return "This platform isn't supported yet.";
      case ProcessError.timeout:
        return "The request timed out. Please try again.";
      case ProcessError.authenticationFailed:
        return "This platform isn't connected yet — we're working on it.";
      case ProcessError.unknown:
        return "An unexpected error occurred.";
    }
  }
}
