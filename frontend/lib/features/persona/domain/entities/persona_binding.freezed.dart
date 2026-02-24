// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'persona_binding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PersonaBinding {

 String get id; String get userId; String get personaId; String? get nickname; bool get isActive; bool get isDefault; int get interactionCount; DateTime get createdAt;
/// Create a copy of PersonaBinding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonaBindingCopyWith<PersonaBinding> get copyWith => _$PersonaBindingCopyWithImpl<PersonaBinding>(this as PersonaBinding, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonaBinding&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.personaId, personaId) || other.personaId == personaId)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.interactionCount, interactionCount) || other.interactionCount == interactionCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,personaId,nickname,isActive,isDefault,interactionCount,createdAt);

@override
String toString() {
  return 'PersonaBinding(id: $id, userId: $userId, personaId: $personaId, nickname: $nickname, isActive: $isActive, isDefault: $isDefault, interactionCount: $interactionCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PersonaBindingCopyWith<$Res>  {
  factory $PersonaBindingCopyWith(PersonaBinding value, $Res Function(PersonaBinding) _then) = _$PersonaBindingCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String personaId, String? nickname, bool isActive, bool isDefault, int interactionCount, DateTime createdAt
});




}
/// @nodoc
class _$PersonaBindingCopyWithImpl<$Res>
    implements $PersonaBindingCopyWith<$Res> {
  _$PersonaBindingCopyWithImpl(this._self, this._then);

  final PersonaBinding _self;
  final $Res Function(PersonaBinding) _then;

/// Create a copy of PersonaBinding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? personaId = null,Object? nickname = freezed,Object? isActive = null,Object? isDefault = null,Object? interactionCount = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,personaId: null == personaId ? _self.personaId : personaId // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,interactionCount: null == interactionCount ? _self.interactionCount : interactionCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonaBinding].
extension PersonaBindingPatterns on PersonaBinding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonaBinding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonaBinding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonaBinding value)  $default,){
final _that = this;
switch (_that) {
case _PersonaBinding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonaBinding value)?  $default,){
final _that = this;
switch (_that) {
case _PersonaBinding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String personaId,  String? nickname,  bool isActive,  bool isDefault,  int interactionCount,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonaBinding() when $default != null:
return $default(_that.id,_that.userId,_that.personaId,_that.nickname,_that.isActive,_that.isDefault,_that.interactionCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String personaId,  String? nickname,  bool isActive,  bool isDefault,  int interactionCount,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PersonaBinding():
return $default(_that.id,_that.userId,_that.personaId,_that.nickname,_that.isActive,_that.isDefault,_that.interactionCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String personaId,  String? nickname,  bool isActive,  bool isDefault,  int interactionCount,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PersonaBinding() when $default != null:
return $default(_that.id,_that.userId,_that.personaId,_that.nickname,_that.isActive,_that.isDefault,_that.interactionCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _PersonaBinding implements PersonaBinding {
  const _PersonaBinding({required this.id, required this.userId, required this.personaId, this.nickname, required this.isActive, required this.isDefault, required this.interactionCount, required this.createdAt});
  

@override final  String id;
@override final  String userId;
@override final  String personaId;
@override final  String? nickname;
@override final  bool isActive;
@override final  bool isDefault;
@override final  int interactionCount;
@override final  DateTime createdAt;

/// Create a copy of PersonaBinding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonaBindingCopyWith<_PersonaBinding> get copyWith => __$PersonaBindingCopyWithImpl<_PersonaBinding>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonaBinding&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.personaId, personaId) || other.personaId == personaId)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.interactionCount, interactionCount) || other.interactionCount == interactionCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,personaId,nickname,isActive,isDefault,interactionCount,createdAt);

@override
String toString() {
  return 'PersonaBinding(id: $id, userId: $userId, personaId: $personaId, nickname: $nickname, isActive: $isActive, isDefault: $isDefault, interactionCount: $interactionCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PersonaBindingCopyWith<$Res> implements $PersonaBindingCopyWith<$Res> {
  factory _$PersonaBindingCopyWith(_PersonaBinding value, $Res Function(_PersonaBinding) _then) = __$PersonaBindingCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String personaId, String? nickname, bool isActive, bool isDefault, int interactionCount, DateTime createdAt
});




}
/// @nodoc
class __$PersonaBindingCopyWithImpl<$Res>
    implements _$PersonaBindingCopyWith<$Res> {
  __$PersonaBindingCopyWithImpl(this._self, this._then);

  final _PersonaBinding _self;
  final $Res Function(_PersonaBinding) _then;

/// Create a copy of PersonaBinding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? personaId = null,Object? nickname = freezed,Object? isActive = null,Object? isDefault = null,Object? interactionCount = null,Object? createdAt = null,}) {
  return _then(_PersonaBinding(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,personaId: null == personaId ? _self.personaId : personaId // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,interactionCount: null == interactionCount ? _self.interactionCount : interactionCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
