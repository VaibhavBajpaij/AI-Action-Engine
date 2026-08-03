import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:reelcraft/data/repository/content_item_repository.dart';
import 'package:reelcraft/network/api_client.dart';
import 'package:reelcraft/network/models/result_dto.dart';
import 'package:reelcraft/network/process_result.dart';
import 'package:reelcraft/services/device_id_service.dart';
import 'package:reelcraft/services/process_service.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockContentItemRepository extends Mock implements ContentItemRepository {}

class MockDeviceIdService extends Mock implements DeviceIdService {}

class FakeResultDto extends Fake implements ResultDto {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeResultDto());
  });

  late MockApiClient mockApiClient;
  late MockContentItemRepository mockRepository;
  late MockDeviceIdService mockDeviceIdService;
  late ProcessService processService;

  const String url = 'https://youtube.com/watch?v=123';
  const String deviceId = 'test-device-id';
  const String jobId = 'test-job-id';

  final dummyResultDto = const ResultDto(
    id: 'uuid',
    title: 'Test',
    platform: 'youtube',
    category: 'tech',
    categoryConfidence: 0.9,
    overview: 'overview',
    checklist: [],
    roadmap: [],
    flashcards: [],
  );

  setUp(() {
    mockApiClient = MockApiClient();
    mockRepository = MockContentItemRepository();
    mockDeviceIdService = MockDeviceIdService();

    when(() => mockDeviceIdService.deviceId).thenReturn(deviceId);

    processService = ProcessService(
      mockApiClient,
      mockRepository,
      mockDeviceIdService,
      pollInterval: Duration.zero,
    );
  });

  group('ProcessService', () {
    test('Successful process flow (submit, poll twice, receive done, parse)', () async {
      when(() => mockApiClient.submitProcess(url, deviceId))
          .thenAnswer((_) async => {'jobId': jobId, 'cached': false});

      int pollCount = 0;
      when(() => mockApiClient.getResult(jobId)).thenAnswer((_) async {
        pollCount++;
        if (pollCount <= 2) {
          return {'status': 'pending'};
        }
        return {
          'status': 'done',
          'data': dummyResultDto.toJson(),
        };
      });

      when(() => mockRepository.saveResultDto(any(), any()))
          .thenAnswer((_) async {});

      final stream = processService.submitUrl(url);
      final results = await stream.toList();

      expect(results.length, 2);
      expect(results[0], const ProcessResult.loading());
      expect(results[1], isA<ProcessResult>());
      
      final resultData = results[1] as ProcessResult;
      resultData.maybeWhen(
        success: (data) {
          expect(data.id, 'uuid');
        },
        orElse: () => fail('Expected success'),
      );

      verify(() => mockApiClient.submitProcess(url, deviceId)).called(1);
      verify(() => mockApiClient.getResult(jobId)).called(3);
      verify(() => mockRepository.saveResultDto(any(), url)).called(1);
    });

    test('cached == true skips polling entirely', () async {
      when(() => mockApiClient.submitProcess(url, deviceId))
          .thenAnswer((_) async => {'jobId': jobId, 'cached': true});

      when(() => mockApiClient.getResult(jobId)).thenAnswer((_) async => {
            'status': 'done',
            'data': dummyResultDto.toJson(),
          });

      when(() => mockRepository.saveResultDto(any(), any()))
          .thenAnswer((_) async {});

      final stream = processService.submitUrl(url);
      final results = await stream.toList();

      expect(results.length, 2);
      verify(() => mockApiClient.submitProcess(url, deviceId)).called(1);
      verify(() => mockApiClient.getResult(jobId)).called(1);
    });

    test('HTTP 429 from POST maps to quotaExceeded', () async {
      when(() => mockApiClient.submitProcess(url, deviceId)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/process'),
          response: Response(
            requestOptions: RequestOptions(path: '/process'),
            statusCode: 429,
          ),
        ),
      );

      final stream = processService.submitUrl(url);
      final results = await stream.toList();

      expect(results, [
        const ProcessResult.loading(),
        const ProcessResult.error(ProcessError.quotaExceeded),
      ]);
    });

    test('GET /result returning status "failed" with error "videoPrivate" maps correctly', () async {
      when(() => mockApiClient.submitProcess(url, deviceId))
          .thenAnswer((_) async => {'jobId': jobId, 'cached': false});

      when(() => mockApiClient.getResult(jobId)).thenAnswer((_) async => {
            'status': 'failed',
            'error': 'videoPrivate',
          });

      final stream = processService.submitUrl(url);
      final results = await stream.toList();

      expect(results, [
        const ProcessResult.loading(),
        const ProcessResult.error(ProcessError.videoPrivate),
      ]);
    });

    test('Unrecognised error string maps to unknown without throwing', () async {
      when(() => mockApiClient.submitProcess(url, deviceId))
          .thenAnswer((_) async => {'jobId': jobId, 'cached': false});

      when(() => mockApiClient.getResult(jobId)).thenAnswer((_) async => {
            'status': 'failed',
            'error': 'someWeirdErrorStringNeverSeenBefore',
          });

      final stream = processService.submitUrl(url);
      final results = await stream.toList();

      expect(results, [
        const ProcessResult.loading(),
        const ProcessResult.error(ProcessError.unknown),
      ]);
    });

    // TODO(production): revert this to 60 when polling is reduced back for production.
    test('Timeout after 150 failed polls (local dev limit)', () async {
      when(() => mockApiClient.submitProcess(url, deviceId))
          .thenAnswer((_) async => {'jobId': jobId, 'cached': false});

      when(() => mockApiClient.getResult(jobId)).thenAnswer((_) async => {
            'status': 'pending',
          });

      final stream = processService.submitUrl(url);
      final results = await stream.toList();

      expect(results, [
        const ProcessResult.loading(),
        const ProcessResult.error(ProcessError.timeout),
      ]);

      verify(() => mockApiClient.submitProcess(url, deviceId)).called(1);
      verify(() => mockApiClient.getResult(jobId)).called(150);
    });

    test('ResultDto with empty checklist/roadmap/flashcards arrays parses fine', () async {
      // This is really testing the parsing but we can do it via the service
      final emptyResultDto = const ResultDto(
        id: 'uuid-2',
        title: 'Test Empty',
        platform: 'youtube',
        category: 'tech',
        categoryConfidence: 0.9,
        overview: 'overview',
        checklist: [],
        roadmap: [],
        flashcards: [],
      );

      when(() => mockApiClient.submitProcess(url, deviceId))
          .thenAnswer((_) async => {'jobId': jobId, 'cached': true});

      when(() => mockApiClient.getResult(jobId)).thenAnswer((_) async => {
            'status': 'done',
            'data': emptyResultDto.toJson(),
          });

      when(() => mockRepository.saveResultDto(any(), any()))
          .thenAnswer((_) async {});

      final stream = processService.submitUrl(url);
      final results = await stream.toList();

      expect(results.length, 2);
      expect(results[1], ProcessResult.success(emptyResultDto));
    });
  });
}
