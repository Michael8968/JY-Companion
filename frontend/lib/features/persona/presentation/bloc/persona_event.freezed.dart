// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'persona_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PersonaEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is PersonaEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PersonaEvent()';
  }
}

/// @nodoc
class $PersonaEventCopyWith<$Res> {
  $PersonaEventCopyWith(PersonaEvent _, $Res Function(PersonaEvent) __);
}

/// Adds pattern-matching-related methods to [PersonaEvent].
extension PersonaEventPatterns on PersonaEvent {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Load value)? load,
    TResult Function(_Bind value)? bind,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Load() when load != null:
        return load(_that);
      case _Bind() when bind != null:
        return bind(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Load value) load,
    required TResult Function(_Bind value) bind,
  }) {
    final _that = this;
    switch (_that) {
      case _Load():
        return load(_that);
      case _Bind():
        return bind(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Load value)? load,
    TResult? Function(_Bind value)? bind,
  }) {
    final _that = this;
    switch (_that) {
      case _Load() when load != null:
        return load(_that);
      case _Bind() when bind != null:
        return bind(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(String personaId, String? nickname)? bind,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Load() when load != null:
        return load();
      case _Bind() when bind != null:
        return bind(_that.personaId, _that.nickname);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(String personaId, String? nickname) bind,
  }) {
    final _that = this;
    switch (_that) {
      case _Load():
        return load();
      case _Bind():
        return bind(_that.personaId, _that.nickname);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(String personaId, String? nickname)? bind,
  }) {
    final _that = this;
    switch (_that) {
      case _Load() when load != null:
        return load();
      case _Bind() when bind != null:
        return bind(_that.personaId, _that.nickname);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Load implements PersonaEvent {
  const _Load();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Load);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PersonaEvent.load()';
  }
}

/// @nodoc

class _Bind implements PersonaEvent {
  const _Bind({required this.personaId, this.nickname});

  final String personaId;
  final String? nickname;

  /// Create a copy of PersonaEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BindCopyWith<_Bind> get copyWith =>
      __$BindCopyWithImpl<_Bind>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Bind &&
            (identical(other.personaId, personaId) ||
                other.personaId == personaId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname));
  }

  @override
  int get hashCode => Object.hash(runtimeType, personaId, nickname);

  @override
  String toString() {
    return 'PersonaEvent.bind(personaId: $personaId, nickname: $nickname)';
  }
}

/// @nodoc
abstract mixin class _$BindCopyWith<$Res>
    implements $PersonaEventCopyWith<$Res> {
  factory _$BindCopyWith(_Bind value, $Res Function(_Bind) _then) =
      __$BindCopyWithImpl;
  @useResult
  $Res call({String personaId, String? nickname});
}

/// @nodoc
class __$BindCopyWithImpl<$Res> implements _$BindCopyWith<$Res> {
  __$BindCopyWithImpl(this._self, this._then);

  final _Bind _self;
  final $Res Function(_Bind) _then;

  /// Create a copy of PersonaEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? personaId = null,
    Object? nickname = freezed,
  }) {
    return _then(_Bind(
      personaId: null == personaId
          ? _self.personaId
          : personaId // ignore: cast_nullable_to_non_nullable
              as String,
      nickname: freezed == nickname
          ? _self.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
