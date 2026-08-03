import 'package:freezed_annotation/freezed_annotation.dart';

part 'result_dto.freezed.dart';
part 'result_dto.g.dart';

@freezed
abstract class ResultDto with _$ResultDto {
  const factory ResultDto({
    required String id,
    required String title,
    required String platform,
    required String category,
    required double categoryConfidence,
    required String overview,
    @Default([]) List<ChecklistDto> checklist,
    @Default([]) List<RoadmapDto> roadmap,
    @Default([]) List<FlashcardDto> flashcards,
    @Default('en') String originalLanguage,
    @Default(false) bool translationFailed,
  }) = _ResultDto;

  factory ResultDto.fromJson(Map<String, dynamic> json) =>
      _$ResultDtoFromJson(json);
}

@freezed
abstract class ChecklistDto with _$ChecklistDto {
  const factory ChecklistDto({
    required int position,
    required String text,
    @Default(false) bool optional,
  }) = _ChecklistDto;

  factory ChecklistDto.fromJson(Map<String, dynamic> json) =>
      _$ChecklistDtoFromJson(json);
}

@freezed
abstract class RoadmapDto with _$RoadmapDto {
  const factory RoadmapDto({
    required int position,
    required String text,
  }) = _RoadmapDto;

  factory RoadmapDto.fromJson(Map<String, dynamic> json) =>
      _$RoadmapDtoFromJson(json);
}

@freezed
abstract class FlashcardDto with _$FlashcardDto {
  const factory FlashcardDto({
    required String front,
    required String back,
  }) = _FlashcardDto;

  factory FlashcardDto.fromJson(Map<String, dynamic> json) =>
      _$FlashcardDtoFromJson(json);
}
