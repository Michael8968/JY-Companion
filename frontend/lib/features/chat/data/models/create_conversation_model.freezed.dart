// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_conversation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateConversationModel {

 String get agentType; String? get personaId; String? get title;
/// Create a copy of CreateConversationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateConversationModelCopyWith<CreateConversationModel> get copyWith => _$CreateConversationModelCopyWithImpl<CreateConversationModel>(this as CreateConversationModel, _$identity);

  /// Serializes this CreateConversationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateConversationModel&&(identical(other.agentType, agentType) || other.agentType == agentType)&&(identical(other.personaId, personaId) || other.personaId == personaId)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,agentType,personaId,title);

@override
String toString() {
  return 'CreateConversationModel(agentType: $agentType, personaId: $personaId, title: $title)';
}


}

/// @nodoc
abstract mixin class $CreateConversationModelCopyWith<$Res>  {
  factory $CreateConversationModelCopyWith(CreateConversationModel value, $Res Function(CreateConversationModel) _then) = _$CreateConversationModelCopyWithImpl;
@useResult
$Res call({
 String agentType, String? personaId, String? title
});




}
/// @nodoc
class _$CreateConversationModelCopyWithImpl<$Res>
    implements $CreateConversationModelCopyWith<$Res> {
  _$CreateConversationModelCopyWithImpl(this._self, this._then);

  final CreateConversationModel _self;
  final $Res Function(CreateConversationModel) _then;

/// Create a copy of CreateConversationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? agentType = null,Object? personaId = freezed,Object? title = freezed,}) {
  return _then(_self.copyWith(
agentType: null == agentType ? _self.agentType : agentType // ignore: cast_nullable_to_non_nullable
as String,personaId: freezed == personaId ? _self.personaId : personaId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateConversationModel].
extension CreateConversationModelPatterns on CreateConversationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateConversationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateConversationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateConversationModel value)  $default,){
final _that = this;
switch (_that) {
case _CreateConversationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateConversationModel value)?  $default,){
final _that = this;
switch (_that) {
case _CreateConversationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String agentType,  String? personaId,  String? title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateConversationModel() when $default != null:
return $default(_that.agentType,_that.personaId,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String agentType,  String? personaId,  String? title)  $default,) {final _that = this;
switch (_that) {
case _CreateConversationModel():
return $default(_that.agentType,_that.personaId,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String agentType,  String? personaId,  String? title)?  $default,) {final _that = this;
switch (_that) {
case _CreateConversationModel() when $default != null:
return $default(_that.agentType,_that.personaId,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateConversationModel implements CreateConversationModel {
  const _CreateConversationModel({required this.agentType, this.personaId, this.title});
  factory _CreateConversationModel.fromJson(Map<String, dynamic> json) => _$CreateConversationModelFromJson(json);

@override final  String agentType;
@override final  String? personaId;
@override final  String? title;

/// Create a copy of CreateConversationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateConversationModelCopyWith<_CreateConversationModel> get copyWith => __$CreateConversationModelCopyWithImpl<_CreateConversationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateConversationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateConversationModel&&(identical(other.agentType, agentType) || other.agentType == agentType)&&(identical(other.personaId, personaId) || other.personaId == personaId)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,agentType,personaId,title);

@override
String toString() {
  return 'CreateConversationModel(agentType: $agentType, personaId: $personaId, title: $title)';
}


}

/// @nodoc
abstract mixin class _$CreateConversationModelCopyWith<$Res> implements $CreateConversationModelCopyWith<$Res> {
  factory _$CreateConversationModelCopyWith(_CreateConversationModel value, $Res Function(_CreateConversationModel) _then) = __$CreateConversationModelCopyWithImpl;
@override @useResult
$Res call({
 String agentType, String? personaId, String? title
});




}
/// @nodoc
class __$CreateConversationModelCopyWithImpl<$Res>
    implements _$CreateConversationModelCopyWith<$Res> {
  __$CreateConversationModelCopyWithImpl(this._self, this._then);

  final _CreateConversationModel _self;
  final $Res Function(_CreateConversationModel) _then;

/// Create a copy of CreateConversationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? agentType = null,Object? personaId = freezed,Object? title = freezed,}) {
  return _then(_CreateConversationModel(
agentType: null == agentType ? _self.agentType : agentType // ignore: cast_nullable_to_non_nullable
as String,personaId: freezed == personaId ? _self.personaId : personaId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
