// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_list_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConversationListEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ConversationListEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ConversationListEvent()';
  }
}

/// @nodoc
class $ConversationListEventCopyWith<$Res> {
  $ConversationListEventCopyWith(
      ConversationListEvent _, $Res Function(ConversationListEvent) __);
}

/// Adds pattern-matching-related methods to [ConversationListEvent].
extension ConversationListEventPatterns on ConversationListEvent {
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
    TResult Function(_Refresh value)? refresh,
    TResult Function(_Create value)? create,
    TResult Function(_Delete value)? delete,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Load() when load != null:
        return load(_that);
      case _Refresh() when refresh != null:
        return refresh(_that);
      case _Create() when create != null:
        return create(_that);
      case _Delete() when delete != null:
        return delete(_that);
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
    required TResult Function(_Refresh value) refresh,
    required TResult Function(_Create value) create,
    required TResult Function(_Delete value) delete,
  }) {
    final _that = this;
    switch (_that) {
      case _Load():
        return load(_that);
      case _Refresh():
        return refresh(_that);
      case _Create():
        return create(_that);
      case _Delete():
        return delete(_that);
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
    TResult? Function(_Refresh value)? refresh,
    TResult? Function(_Create value)? create,
    TResult? Function(_Delete value)? delete,
  }) {
    final _that = this;
    switch (_that) {
      case _Load() when load != null:
        return load(_that);
      case _Refresh() when refresh != null:
        return refresh(_that);
      case _Create() when create != null:
        return create(_that);
      case _Delete() when delete != null:
        return delete(_that);
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
    TResult Function()? refresh,
    TResult Function(String agentType, String? personaId, String? title)?
        create,
    TResult Function(String conversationId)? delete,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Load() when load != null:
        return load();
      case _Refresh() when refresh != null:
        return refresh();
      case _Create() when create != null:
        return create(_that.agentType, _that.personaId, _that.title);
      case _Delete() when delete != null:
        return delete(_that.conversationId);
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
    required TResult Function() refresh,
    required TResult Function(
            String agentType, String? personaId, String? title)
        create,
    required TResult Function(String conversationId) delete,
  }) {
    final _that = this;
    switch (_that) {
      case _Load():
        return load();
      case _Refresh():
        return refresh();
      case _Create():
        return create(_that.agentType, _that.personaId, _that.title);
      case _Delete():
        return delete(_that.conversationId);
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
    TResult? Function()? refresh,
    TResult? Function(String agentType, String? personaId, String? title)?
        create,
    TResult? Function(String conversationId)? delete,
  }) {
    final _that = this;
    switch (_that) {
      case _Load() when load != null:
        return load();
      case _Refresh() when refresh != null:
        return refresh();
      case _Create() when create != null:
        return create(_that.agentType, _that.personaId, _that.title);
      case _Delete() when delete != null:
        return delete(_that.conversationId);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Load implements ConversationListEvent {
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
    return 'ConversationListEvent.load()';
  }
}

/// @nodoc

class _Refresh implements ConversationListEvent {
  const _Refresh();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Refresh);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ConversationListEvent.refresh()';
  }
}

/// @nodoc

class _Create implements ConversationListEvent {
  const _Create({required this.agentType, this.personaId, this.title});

  final String agentType;
  final String? personaId;
  final String? title;

  /// Create a copy of ConversationListEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CreateCopyWith<_Create> get copyWith =>
      __$CreateCopyWithImpl<_Create>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Create &&
            (identical(other.agentType, agentType) ||
                other.agentType == agentType) &&
            (identical(other.personaId, personaId) ||
                other.personaId == personaId) &&
            (identical(other.title, title) || other.title == title));
  }

  @override
  int get hashCode => Object.hash(runtimeType, agentType, personaId, title);

  @override
  String toString() {
    return 'ConversationListEvent.create(agentType: $agentType, personaId: $personaId, title: $title)';
  }
}

/// @nodoc
abstract mixin class _$CreateCopyWith<$Res>
    implements $ConversationListEventCopyWith<$Res> {
  factory _$CreateCopyWith(_Create value, $Res Function(_Create) _then) =
      __$CreateCopyWithImpl;
  @useResult
  $Res call({String agentType, String? personaId, String? title});
}

/// @nodoc
class __$CreateCopyWithImpl<$Res> implements _$CreateCopyWith<$Res> {
  __$CreateCopyWithImpl(this._self, this._then);

  final _Create _self;
  final $Res Function(_Create) _then;

  /// Create a copy of ConversationListEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? agentType = null,
    Object? personaId = freezed,
    Object? title = freezed,
  }) {
    return _then(_Create(
      agentType: null == agentType
          ? _self.agentType
          : agentType // ignore: cast_nullable_to_non_nullable
              as String,
      personaId: freezed == personaId
          ? _self.personaId
          : personaId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _Delete implements ConversationListEvent {
  const _Delete(this.conversationId);

  final String conversationId;

  /// Create a copy of ConversationListEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeleteCopyWith<_Delete> get copyWith =>
      __$DeleteCopyWithImpl<_Delete>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Delete &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, conversationId);

  @override
  String toString() {
    return 'ConversationListEvent.delete(conversationId: $conversationId)';
  }
}

/// @nodoc
abstract mixin class _$DeleteCopyWith<$Res>
    implements $ConversationListEventCopyWith<$Res> {
  factory _$DeleteCopyWith(_Delete value, $Res Function(_Delete) _then) =
      __$DeleteCopyWithImpl;
  @useResult
  $Res call({String conversationId});
}

/// @nodoc
class __$DeleteCopyWithImpl<$Res> implements _$DeleteCopyWith<$Res> {
  __$DeleteCopyWithImpl(this._self, this._then);

  final _Delete _self;
  final $Res Function(_Delete) _then;

  /// Create a copy of ConversationListEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? conversationId = null,
  }) {
    return _then(_Delete(
      null == conversationId
          ? _self.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
