// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'persona_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PersonaState {

 List<Persona> get personas; List<PersonaBinding> get bindings; bool get isLoading; bool get isBinding; String? get errorMessage; String? get successMessage;
/// Create a copy of PersonaState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonaStateCopyWith<PersonaState> get copyWith => _$PersonaStateCopyWithImpl<PersonaState>(this as PersonaState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonaState&&const DeepCollectionEquality().equals(other.personas, personas)&&const DeepCollectionEquality().equals(other.bindings, bindings)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isBinding, isBinding) || other.isBinding == isBinding)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(personas),const DeepCollectionEquality().hash(bindings),isLoading,isBinding,errorMessage,successMessage);

@override
String toString() {
  return 'PersonaState(personas: $personas, bindings: $bindings, isLoading: $isLoading, isBinding: $isBinding, errorMessage: $errorMessage, successMessage: $successMessage)';
}


}

/// @nodoc
abstract mixin class $PersonaStateCopyWith<$Res>  {
  factory $PersonaStateCopyWith(PersonaState value, $Res Function(PersonaState) _then) = _$PersonaStateCopyWithImpl;
@useResult
$Res call({
 List<Persona> personas, List<PersonaBinding> bindings, bool isLoading, bool isBinding, String? errorMessage, String? successMessage
});




}
/// @nodoc
class _$PersonaStateCopyWithImpl<$Res>
    implements $PersonaStateCopyWith<$Res> {
  _$PersonaStateCopyWithImpl(this._self, this._then);

  final PersonaState _self;
  final $Res Function(PersonaState) _then;

/// Create a copy of PersonaState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? personas = null,Object? bindings = null,Object? isLoading = null,Object? isBinding = null,Object? errorMessage = freezed,Object? successMessage = freezed,}) {
  return _then(_self.copyWith(
personas: null == personas ? _self.personas : personas // ignore: cast_nullable_to_non_nullable
as List<Persona>,bindings: null == bindings ? _self.bindings : bindings // ignore: cast_nullable_to_non_nullable
as List<PersonaBinding>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isBinding: null == isBinding ? _self.isBinding : isBinding // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,successMessage: freezed == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonaState].
extension PersonaStatePatterns on PersonaState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonaState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonaState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonaState value)  $default,){
final _that = this;
switch (_that) {
case _PersonaState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonaState value)?  $default,){
final _that = this;
switch (_that) {
case _PersonaState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Persona> personas,  List<PersonaBinding> bindings,  bool isLoading,  bool isBinding,  String? errorMessage,  String? successMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonaState() when $default != null:
return $default(_that.personas,_that.bindings,_that.isLoading,_that.isBinding,_that.errorMessage,_that.successMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Persona> personas,  List<PersonaBinding> bindings,  bool isLoading,  bool isBinding,  String? errorMessage,  String? successMessage)  $default,) {final _that = this;
switch (_that) {
case _PersonaState():
return $default(_that.personas,_that.bindings,_that.isLoading,_that.isBinding,_that.errorMessage,_that.successMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Persona> personas,  List<PersonaBinding> bindings,  bool isLoading,  bool isBinding,  String? errorMessage,  String? successMessage)?  $default,) {final _that = this;
switch (_that) {
case _PersonaState() when $default != null:
return $default(_that.personas,_that.bindings,_that.isLoading,_that.isBinding,_that.errorMessage,_that.successMessage);case _:
  return null;

}
}

}

/// @nodoc


class _PersonaState implements PersonaState {
  const _PersonaState({final  List<Persona> personas = const [], final  List<PersonaBinding> bindings = const [], this.isLoading = false, this.isBinding = false, this.errorMessage, this.successMessage}): _personas = personas,_bindings = bindings;
  

 final  List<Persona> _personas;
@override@JsonKey() List<Persona> get personas {
  if (_personas is EqualUnmodifiableListView) return _personas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_personas);
}

 final  List<PersonaBinding> _bindings;
@override@JsonKey() List<PersonaBinding> get bindings {
  if (_bindings is EqualUnmodifiableListView) return _bindings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bindings);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isBinding;
@override final  String? errorMessage;
@override final  String? successMessage;

/// Create a copy of PersonaState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonaStateCopyWith<_PersonaState> get copyWith => __$PersonaStateCopyWithImpl<_PersonaState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonaState&&const DeepCollectionEquality().equals(other._personas, _personas)&&const DeepCollectionEquality().equals(other._bindings, _bindings)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isBinding, isBinding) || other.isBinding == isBinding)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_personas),const DeepCollectionEquality().hash(_bindings),isLoading,isBinding,errorMessage,successMessage);

@override
String toString() {
  return 'PersonaState(personas: $personas, bindings: $bindings, isLoading: $isLoading, isBinding: $isBinding, errorMessage: $errorMessage, successMessage: $successMessage)';
}


}

/// @nodoc
abstract mixin class _$PersonaStateCopyWith<$Res> implements $PersonaStateCopyWith<$Res> {
  factory _$PersonaStateCopyWith(_PersonaState value, $Res Function(_PersonaState) _then) = __$PersonaStateCopyWithImpl;
@override @useResult
$Res call({
 List<Persona> personas, List<PersonaBinding> bindings, bool isLoading, bool isBinding, String? errorMessage, String? successMessage
});




}
/// @nodoc
class __$PersonaStateCopyWithImpl<$Res>
    implements _$PersonaStateCopyWith<$Res> {
  __$PersonaStateCopyWithImpl(this._self, this._then);

  final _PersonaState _self;
  final $Res Function(_PersonaState) _then;

/// Create a copy of PersonaState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? personas = null,Object? bindings = null,Object? isLoading = null,Object? isBinding = null,Object? errorMessage = freezed,Object? successMessage = freezed,}) {
  return _then(_PersonaState(
personas: null == personas ? _self._personas : personas // ignore: cast_nullable_to_non_nullable
as List<Persona>,bindings: null == bindings ? _self._bindings : bindings // ignore: cast_nullable_to_non_nullable
as List<PersonaBinding>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isBinding: null == isBinding ? _self.isBinding : isBinding // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,successMessage: freezed == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
