// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ResultDto {

 String get id; String get title; String get platform; String get category; double get categoryConfidence; String get overview; List<ChecklistDto> get checklist; List<RoadmapDto> get roadmap; List<FlashcardDto> get flashcards; String get originalLanguage; bool get translationFailed;
/// Create a copy of ResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultDtoCopyWith<ResultDto> get copyWith => _$ResultDtoCopyWithImpl<ResultDto>(this as ResultDto, _$identity);

  /// Serializes this ResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.category, category) || other.category == category)&&(identical(other.categoryConfidence, categoryConfidence) || other.categoryConfidence == categoryConfidence)&&(identical(other.overview, overview) || other.overview == overview)&&const DeepCollectionEquality().equals(other.checklist, checklist)&&const DeepCollectionEquality().equals(other.roadmap, roadmap)&&const DeepCollectionEquality().equals(other.flashcards, flashcards)&&(identical(other.originalLanguage, originalLanguage) || other.originalLanguage == originalLanguage)&&(identical(other.translationFailed, translationFailed) || other.translationFailed == translationFailed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,platform,category,categoryConfidence,overview,const DeepCollectionEquality().hash(checklist),const DeepCollectionEquality().hash(roadmap),const DeepCollectionEquality().hash(flashcards),originalLanguage,translationFailed);

@override
String toString() {
  return 'ResultDto(id: $id, title: $title, platform: $platform, category: $category, categoryConfidence: $categoryConfidence, overview: $overview, checklist: $checklist, roadmap: $roadmap, flashcards: $flashcards, originalLanguage: $originalLanguage, translationFailed: $translationFailed)';
}


}

/// @nodoc
abstract mixin class $ResultDtoCopyWith<$Res>  {
  factory $ResultDtoCopyWith(ResultDto value, $Res Function(ResultDto) _then) = _$ResultDtoCopyWithImpl;
@useResult
$Res call({
 String id, String title, String platform, String category, double categoryConfidence, String overview, List<ChecklistDto> checklist, List<RoadmapDto> roadmap, List<FlashcardDto> flashcards, String originalLanguage, bool translationFailed
});




}
/// @nodoc
class _$ResultDtoCopyWithImpl<$Res>
    implements $ResultDtoCopyWith<$Res> {
  _$ResultDtoCopyWithImpl(this._self, this._then);

  final ResultDto _self;
  final $Res Function(ResultDto) _then;

/// Create a copy of ResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? platform = null,Object? category = null,Object? categoryConfidence = null,Object? overview = null,Object? checklist = null,Object? roadmap = null,Object? flashcards = null,Object? originalLanguage = null,Object? translationFailed = null,}) {
  return _then(ResultDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,categoryConfidence: null == categoryConfidence ? _self.categoryConfidence : categoryConfidence // ignore: cast_nullable_to_non_nullable
as double,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String,checklist: null == checklist ? _self.checklist : checklist // ignore: cast_nullable_to_non_nullable
as List<ChecklistDto>,roadmap: null == roadmap ? _self.roadmap : roadmap // ignore: cast_nullable_to_non_nullable
as List<RoadmapDto>,flashcards: null == flashcards ? _self.flashcards : flashcards // ignore: cast_nullable_to_non_nullable
as List<FlashcardDto>,originalLanguage: null == originalLanguage ? _self.originalLanguage : originalLanguage // ignore: cast_nullable_to_non_nullable
as String,translationFailed: null == translationFailed ? _self.translationFailed : translationFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ResultDto].
extension ResultDtoPatterns on ResultDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResultDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResultDto value)  $default,){
final _that = this;
switch (_that) {
case _ResultDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _ResultDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String platform,  String category,  double categoryConfidence,  String overview,  List<ChecklistDto> checklist,  List<RoadmapDto> roadmap,  List<FlashcardDto> flashcards,  String originalLanguage,  bool translationFailed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResultDto() when $default != null:
return $default(_that.id,_that.title,_that.platform,_that.category,_that.categoryConfidence,_that.overview,_that.checklist,_that.roadmap,_that.flashcards,_that.originalLanguage,_that.translationFailed);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String platform,  String category,  double categoryConfidence,  String overview,  List<ChecklistDto> checklist,  List<RoadmapDto> roadmap,  List<FlashcardDto> flashcards,  String originalLanguage,  bool translationFailed)  $default,) {final _that = this;
switch (_that) {
case _ResultDto():
return $default(_that.id,_that.title,_that.platform,_that.category,_that.categoryConfidence,_that.overview,_that.checklist,_that.roadmap,_that.flashcards,_that.originalLanguage,_that.translationFailed);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String platform,  String category,  double categoryConfidence,  String overview,  List<ChecklistDto> checklist,  List<RoadmapDto> roadmap,  List<FlashcardDto> flashcards,  String originalLanguage,  bool translationFailed)?  $default,) {final _that = this;
switch (_that) {
case _ResultDto() when $default != null:
return $default(_that.id,_that.title,_that.platform,_that.category,_that.categoryConfidence,_that.overview,_that.checklist,_that.roadmap,_that.flashcards,_that.originalLanguage,_that.translationFailed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResultDto implements ResultDto {
  const _ResultDto({required this.id, required this.title, required this.platform, required this.category, required this.categoryConfidence, required this.overview,  List<ChecklistDto> checklist = const [],  List<RoadmapDto> roadmap = const [],  List<FlashcardDto> flashcards = const [], this.originalLanguage = 'en', this.translationFailed = false}): _checklist = checklist,_roadmap = roadmap,_flashcards = flashcards;
  factory _ResultDto.fromJson(Map<String, dynamic> json) => _$ResultDtoFromJson(json);

@override final  String id;
@override final  String title;
@override final  String platform;
@override final  String category;
@override final  double categoryConfidence;
@override final  String overview;
 final  List<ChecklistDto> _checklist;
@override@JsonKey() List<ChecklistDto> get checklist {
  if (_checklist is EqualUnmodifiableListView) return _checklist;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_checklist);
}

 final  List<RoadmapDto> _roadmap;
@override@JsonKey() List<RoadmapDto> get roadmap {
  if (_roadmap is EqualUnmodifiableListView) return _roadmap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roadmap);
}

 final  List<FlashcardDto> _flashcards;
@override@JsonKey() List<FlashcardDto> get flashcards {
  if (_flashcards is EqualUnmodifiableListView) return _flashcards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_flashcards);
}

@override@JsonKey() final  String originalLanguage;
@override@JsonKey() final  bool translationFailed;

/// Create a copy of ResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultDtoCopyWith<_ResultDto> get copyWith => __$ResultDtoCopyWithImpl<_ResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResultDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.category, category) || other.category == category)&&(identical(other.categoryConfidence, categoryConfidence) || other.categoryConfidence == categoryConfidence)&&(identical(other.overview, overview) || other.overview == overview)&&const DeepCollectionEquality().equals(other._checklist, _checklist)&&const DeepCollectionEquality().equals(other._roadmap, _roadmap)&&const DeepCollectionEquality().equals(other._flashcards, _flashcards)&&(identical(other.originalLanguage, originalLanguage) || other.originalLanguage == originalLanguage)&&(identical(other.translationFailed, translationFailed) || other.translationFailed == translationFailed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,platform,category,categoryConfidence,overview,const DeepCollectionEquality().hash(_checklist),const DeepCollectionEquality().hash(_roadmap),const DeepCollectionEquality().hash(_flashcards),originalLanguage,translationFailed);

@override
String toString() {
  return 'ResultDto(id: $id, title: $title, platform: $platform, category: $category, categoryConfidence: $categoryConfidence, overview: $overview, checklist: $checklist, roadmap: $roadmap, flashcards: $flashcards, originalLanguage: $originalLanguage, translationFailed: $translationFailed)';
}


}

/// @nodoc
abstract mixin class _$ResultDtoCopyWith<$Res> implements $ResultDtoCopyWith<$Res> {
  factory _$ResultDtoCopyWith(_ResultDto value, $Res Function(_ResultDto) _then) = __$ResultDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String platform, String category, double categoryConfidence, String overview, List<ChecklistDto> checklist, List<RoadmapDto> roadmap, List<FlashcardDto> flashcards, String originalLanguage, bool translationFailed
});




}
/// @nodoc
class __$ResultDtoCopyWithImpl<$Res>
    implements _$ResultDtoCopyWith<$Res> {
  __$ResultDtoCopyWithImpl(this._self, this._then);

  final _ResultDto _self;
  final $Res Function(_ResultDto) _then;

/// Create a copy of ResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? platform = null,Object? category = null,Object? categoryConfidence = null,Object? overview = null,Object? checklist = null,Object? roadmap = null,Object? flashcards = null,Object? originalLanguage = null,Object? translationFailed = null,}) {
  return _then(_ResultDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,categoryConfidence: null == categoryConfidence ? _self.categoryConfidence : categoryConfidence // ignore: cast_nullable_to_non_nullable
as double,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String,checklist: null == checklist ? _self._checklist : checklist // ignore: cast_nullable_to_non_nullable
as List<ChecklistDto>,roadmap: null == roadmap ? _self._roadmap : roadmap // ignore: cast_nullable_to_non_nullable
as List<RoadmapDto>,flashcards: null == flashcards ? _self._flashcards : flashcards // ignore: cast_nullable_to_non_nullable
as List<FlashcardDto>,originalLanguage: null == originalLanguage ? _self.originalLanguage : originalLanguage // ignore: cast_nullable_to_non_nullable
as String,translationFailed: null == translationFailed ? _self.translationFailed : translationFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ChecklistDto {

 int get position; String get text; bool get optional;
/// Create a copy of ChecklistDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChecklistDtoCopyWith<ChecklistDto> get copyWith => _$ChecklistDtoCopyWithImpl<ChecklistDto>(this as ChecklistDto, _$identity);

  /// Serializes this ChecklistDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChecklistDto&&(identical(other.position, position) || other.position == position)&&(identical(other.text, text) || other.text == text)&&(identical(other.optional, optional) || other.optional == optional));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,position,text,optional);

@override
String toString() {
  return 'ChecklistDto(position: $position, text: $text, optional: $optional)';
}


}

/// @nodoc
abstract mixin class $ChecklistDtoCopyWith<$Res>  {
  factory $ChecklistDtoCopyWith(ChecklistDto value, $Res Function(ChecklistDto) _then) = _$ChecklistDtoCopyWithImpl;
@useResult
$Res call({
 int position, String text, bool optional
});




}
/// @nodoc
class _$ChecklistDtoCopyWithImpl<$Res>
    implements $ChecklistDtoCopyWith<$Res> {
  _$ChecklistDtoCopyWithImpl(this._self, this._then);

  final ChecklistDto _self;
  final $Res Function(ChecklistDto) _then;

/// Create a copy of ChecklistDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? position = null,Object? text = null,Object? optional = null,}) {
  return _then(ChecklistDto(
position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,optional: null == optional ? _self.optional : optional // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChecklistDto].
extension ChecklistDtoPatterns on ChecklistDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChecklistDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChecklistDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChecklistDto value)  $default,){
final _that = this;
switch (_that) {
case _ChecklistDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChecklistDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChecklistDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int position,  String text,  bool optional)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChecklistDto() when $default != null:
return $default(_that.position,_that.text,_that.optional);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int position,  String text,  bool optional)  $default,) {final _that = this;
switch (_that) {
case _ChecklistDto():
return $default(_that.position,_that.text,_that.optional);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int position,  String text,  bool optional)?  $default,) {final _that = this;
switch (_that) {
case _ChecklistDto() when $default != null:
return $default(_that.position,_that.text,_that.optional);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChecklistDto implements ChecklistDto {
  const _ChecklistDto({required this.position, required this.text, this.optional = false});
  factory _ChecklistDto.fromJson(Map<String, dynamic> json) => _$ChecklistDtoFromJson(json);

@override final  int position;
@override final  String text;
@override@JsonKey() final  bool optional;

/// Create a copy of ChecklistDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChecklistDtoCopyWith<_ChecklistDto> get copyWith => __$ChecklistDtoCopyWithImpl<_ChecklistDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChecklistDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChecklistDto&&(identical(other.position, position) || other.position == position)&&(identical(other.text, text) || other.text == text)&&(identical(other.optional, optional) || other.optional == optional));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,position,text,optional);

@override
String toString() {
  return 'ChecklistDto(position: $position, text: $text, optional: $optional)';
}


}

/// @nodoc
abstract mixin class _$ChecklistDtoCopyWith<$Res> implements $ChecklistDtoCopyWith<$Res> {
  factory _$ChecklistDtoCopyWith(_ChecklistDto value, $Res Function(_ChecklistDto) _then) = __$ChecklistDtoCopyWithImpl;
@override @useResult
$Res call({
 int position, String text, bool optional
});




}
/// @nodoc
class __$ChecklistDtoCopyWithImpl<$Res>
    implements _$ChecklistDtoCopyWith<$Res> {
  __$ChecklistDtoCopyWithImpl(this._self, this._then);

  final _ChecklistDto _self;
  final $Res Function(_ChecklistDto) _then;

/// Create a copy of ChecklistDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? position = null,Object? text = null,Object? optional = null,}) {
  return _then(_ChecklistDto(
position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,optional: null == optional ? _self.optional : optional // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RoadmapDto {

 int get position; String get text;
/// Create a copy of RoadmapDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoadmapDtoCopyWith<RoadmapDto> get copyWith => _$RoadmapDtoCopyWithImpl<RoadmapDto>(this as RoadmapDto, _$identity);

  /// Serializes this RoadmapDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoadmapDto&&(identical(other.position, position) || other.position == position)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,position,text);

@override
String toString() {
  return 'RoadmapDto(position: $position, text: $text)';
}


}

/// @nodoc
abstract mixin class $RoadmapDtoCopyWith<$Res>  {
  factory $RoadmapDtoCopyWith(RoadmapDto value, $Res Function(RoadmapDto) _then) = _$RoadmapDtoCopyWithImpl;
@useResult
$Res call({
 int position, String text
});




}
/// @nodoc
class _$RoadmapDtoCopyWithImpl<$Res>
    implements $RoadmapDtoCopyWith<$Res> {
  _$RoadmapDtoCopyWithImpl(this._self, this._then);

  final RoadmapDto _self;
  final $Res Function(RoadmapDto) _then;

/// Create a copy of RoadmapDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? position = null,Object? text = null,}) {
  return _then(RoadmapDto(
position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RoadmapDto].
extension RoadmapDtoPatterns on RoadmapDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoadmapDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoadmapDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoadmapDto value)  $default,){
final _that = this;
switch (_that) {
case _RoadmapDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoadmapDto value)?  $default,){
final _that = this;
switch (_that) {
case _RoadmapDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int position,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoadmapDto() when $default != null:
return $default(_that.position,_that.text);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int position,  String text)  $default,) {final _that = this;
switch (_that) {
case _RoadmapDto():
return $default(_that.position,_that.text);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int position,  String text)?  $default,) {final _that = this;
switch (_that) {
case _RoadmapDto() when $default != null:
return $default(_that.position,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoadmapDto implements RoadmapDto {
  const _RoadmapDto({required this.position, required this.text});
  factory _RoadmapDto.fromJson(Map<String, dynamic> json) => _$RoadmapDtoFromJson(json);

@override final  int position;
@override final  String text;

/// Create a copy of RoadmapDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoadmapDtoCopyWith<_RoadmapDto> get copyWith => __$RoadmapDtoCopyWithImpl<_RoadmapDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoadmapDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoadmapDto&&(identical(other.position, position) || other.position == position)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,position,text);

@override
String toString() {
  return 'RoadmapDto(position: $position, text: $text)';
}


}

/// @nodoc
abstract mixin class _$RoadmapDtoCopyWith<$Res> implements $RoadmapDtoCopyWith<$Res> {
  factory _$RoadmapDtoCopyWith(_RoadmapDto value, $Res Function(_RoadmapDto) _then) = __$RoadmapDtoCopyWithImpl;
@override @useResult
$Res call({
 int position, String text
});




}
/// @nodoc
class __$RoadmapDtoCopyWithImpl<$Res>
    implements _$RoadmapDtoCopyWith<$Res> {
  __$RoadmapDtoCopyWithImpl(this._self, this._then);

  final _RoadmapDto _self;
  final $Res Function(_RoadmapDto) _then;

/// Create a copy of RoadmapDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? position = null,Object? text = null,}) {
  return _then(_RoadmapDto(
position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$FlashcardDto {

 String get front; String get back;
/// Create a copy of FlashcardDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlashcardDtoCopyWith<FlashcardDto> get copyWith => _$FlashcardDtoCopyWithImpl<FlashcardDto>(this as FlashcardDto, _$identity);

  /// Serializes this FlashcardDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FlashcardDto&&(identical(other.front, front) || other.front == front)&&(identical(other.back, back) || other.back == back));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,front,back);

@override
String toString() {
  return 'FlashcardDto(front: $front, back: $back)';
}


}

/// @nodoc
abstract mixin class $FlashcardDtoCopyWith<$Res>  {
  factory $FlashcardDtoCopyWith(FlashcardDto value, $Res Function(FlashcardDto) _then) = _$FlashcardDtoCopyWithImpl;
@useResult
$Res call({
 String front, String back
});




}
/// @nodoc
class _$FlashcardDtoCopyWithImpl<$Res>
    implements $FlashcardDtoCopyWith<$Res> {
  _$FlashcardDtoCopyWithImpl(this._self, this._then);

  final FlashcardDto _self;
  final $Res Function(FlashcardDto) _then;

/// Create a copy of FlashcardDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? front = null,Object? back = null,}) {
  return _then(FlashcardDto(
front: null == front ? _self.front : front // ignore: cast_nullable_to_non_nullable
as String,back: null == back ? _self.back : back // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FlashcardDto].
extension FlashcardDtoPatterns on FlashcardDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FlashcardDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FlashcardDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FlashcardDto value)  $default,){
final _that = this;
switch (_that) {
case _FlashcardDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FlashcardDto value)?  $default,){
final _that = this;
switch (_that) {
case _FlashcardDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String front,  String back)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FlashcardDto() when $default != null:
return $default(_that.front,_that.back);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String front,  String back)  $default,) {final _that = this;
switch (_that) {
case _FlashcardDto():
return $default(_that.front,_that.back);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String front,  String back)?  $default,) {final _that = this;
switch (_that) {
case _FlashcardDto() when $default != null:
return $default(_that.front,_that.back);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FlashcardDto implements FlashcardDto {
  const _FlashcardDto({required this.front, required this.back});
  factory _FlashcardDto.fromJson(Map<String, dynamic> json) => _$FlashcardDtoFromJson(json);

@override final  String front;
@override final  String back;

/// Create a copy of FlashcardDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlashcardDtoCopyWith<_FlashcardDto> get copyWith => __$FlashcardDtoCopyWithImpl<_FlashcardDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FlashcardDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FlashcardDto&&(identical(other.front, front) || other.front == front)&&(identical(other.back, back) || other.back == back));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,front,back);

@override
String toString() {
  return 'FlashcardDto(front: $front, back: $back)';
}


}

/// @nodoc
abstract mixin class _$FlashcardDtoCopyWith<$Res> implements $FlashcardDtoCopyWith<$Res> {
  factory _$FlashcardDtoCopyWith(_FlashcardDto value, $Res Function(_FlashcardDto) _then) = __$FlashcardDtoCopyWithImpl;
@override @useResult
$Res call({
 String front, String back
});




}
/// @nodoc
class __$FlashcardDtoCopyWithImpl<$Res>
    implements _$FlashcardDtoCopyWith<$Res> {
  __$FlashcardDtoCopyWithImpl(this._self, this._then);

  final _FlashcardDto _self;
  final $Res Function(_FlashcardDto) _then;

/// Create a copy of FlashcardDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? front = null,Object? back = null,}) {
  return _then(_FlashcardDto(
front: null == front ? _self.front : front // ignore: cast_nullable_to_non_nullable
as String,back: null == back ? _self.back : back // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
