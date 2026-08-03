// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ResultDto _$ResultDtoFromJson(Map<String, dynamic> json) => _ResultDto(
  id: json['id'] as String,
  title: json['title'] as String,
  platform: json['platform'] as String,
  category: json['category'] as String,
  categoryConfidence: (json['categoryConfidence'] as num).toDouble(),
  overview: json['overview'] as String,
  checklist:
      (json['checklist'] as List<dynamic>?)
          ?.map((e) => ChecklistDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  roadmap:
      (json['roadmap'] as List<dynamic>?)
          ?.map((e) => RoadmapDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  flashcards:
      (json['flashcards'] as List<dynamic>?)
          ?.map((e) => FlashcardDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  originalLanguage: json['originalLanguage'] as String? ?? 'en',
  translationFailed: json['translationFailed'] as bool? ?? false,
);

Map<String, dynamic> _$ResultDtoToJson(_ResultDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'platform': instance.platform,
      'category': instance.category,
      'categoryConfidence': instance.categoryConfidence,
      'overview': instance.overview,
      'checklist': instance.checklist,
      'roadmap': instance.roadmap,
      'flashcards': instance.flashcards,
      'originalLanguage': instance.originalLanguage,
      'translationFailed': instance.translationFailed,
    };

_ChecklistDto _$ChecklistDtoFromJson(Map<String, dynamic> json) =>
    _ChecklistDto(
      position: (json['position'] as num).toInt(),
      text: json['text'] as String,
      optional: json['optional'] as bool? ?? false,
    );

Map<String, dynamic> _$ChecklistDtoToJson(_ChecklistDto instance) =>
    <String, dynamic>{
      'position': instance.position,
      'text': instance.text,
      'optional': instance.optional,
    };

_RoadmapDto _$RoadmapDtoFromJson(Map<String, dynamic> json) => _RoadmapDto(
  position: (json['position'] as num).toInt(),
  text: json['text'] as String,
);

Map<String, dynamic> _$RoadmapDtoToJson(_RoadmapDto instance) =>
    <String, dynamic>{'position': instance.position, 'text': instance.text};

_FlashcardDto _$FlashcardDtoFromJson(Map<String, dynamic> json) =>
    _FlashcardDto(front: json['front'] as String, back: json['back'] as String);

Map<String, dynamic> _$FlashcardDtoToJson(_FlashcardDto instance) =>
    <String, dynamic>{'front': instance.front, 'back': instance.back};
