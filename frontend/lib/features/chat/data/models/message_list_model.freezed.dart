// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_list_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageListModel {
  List<MessageModel> get messages;
  int get total;
  int get page;
  int get size;

  /// Create a copy of MessageListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MessageListModelCopyWith<MessageListModel> get copyWith =>
      _$MessageListModelCopyWithImpl<MessageListModel>(
          this as MessageListModel, _$identity);

  /// Serializes this MessageListModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MessageListModel &&
            const DeepCollectionEquality().equals(other.messages, messages) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.size, size) || other.size == size));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(messages), total, page, size);

  @override
  String toString() {
    return 'MessageListModel(messages: $messages, total: $total, page: $page, size: $size)';
  }
}

/// @nodoc
abstract mixin class $MessageListModelCopyWith<$Res> {
  factory $MessageListModelCopyWith(
          MessageListModel value, $Res Function(MessageListModel) _then) =
      _$MessageListModelCopyWithImpl;
  @useResult
  $Res call({List<MessageModel> messages, int total, int page, int size});
}

/// @nodoc
class _$MessageListModelCopyWithImpl<$Res>
    implements $MessageListModelCopyWith<$Res> {
  _$MessageListModelCopyWithImpl(this._self, this._then);

  final MessageListModel _self;
  final $Res Function(MessageListModel) _then;

  /// Create a copy of MessageListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? total = null,
    Object? page = null,
    Object? size = null,
  }) {
    return _then(_self.copyWith(
      messages: null == messages
          ? _self.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<MessageModel>,
      total: null == total
          ? _self.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _self.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      size: null == size
          ? _self.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [MessageListModel].
extension MessageListModelPatterns on MessageListModel {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MessageListModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MessageListModel() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_MessageListModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageListModel():
        return $default(_that);
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
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MessageListModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageListModel() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            List<MessageModel> messages, int total, int page, int size)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MessageListModel() when $default != null:
        return $default(_that.messages, _that.total, _that.page, _that.size);
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
  TResult when<TResult extends Object?>(
    TResult Function(List<MessageModel> messages, int total, int page, int size)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageListModel():
        return $default(_that.messages, _that.total, _that.page, _that.size);
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
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            List<MessageModel> messages, int total, int page, int size)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageListModel() when $default != null:
        return $default(_that.messages, _that.total, _that.page, _that.size);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _MessageListModel implements MessageListModel {
  const _MessageListModel(
      {required final List<MessageModel> messages,
      required this.total,
      required this.page,
      required this.size})
      : _messages = messages;
  factory _MessageListModel.fromJson(Map<String, dynamic> json) =>
      _$MessageListModelFromJson(json);

  final List<MessageModel> _messages;
  @override
  List<MessageModel> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final int total;
  @override
  final int page;
  @override
  final int size;

  /// Create a copy of MessageListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MessageListModelCopyWith<_MessageListModel> get copyWith =>
      __$MessageListModelCopyWithImpl<_MessageListModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MessageListModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MessageListModel &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.size, size) || other.size == size));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_messages), total, page, size);

  @override
  String toString() {
    return 'MessageListModel(messages: $messages, total: $total, page: $page, size: $size)';
  }
}

/// @nodoc
abstract mixin class _$MessageListModelCopyWith<$Res>
    implements $MessageListModelCopyWith<$Res> {
  factory _$MessageListModelCopyWith(
          _MessageListModel value, $Res Function(_MessageListModel) _then) =
      __$MessageListModelCopyWithImpl;
  @override
  @useResult
  $Res call({List<MessageModel> messages, int total, int page, int size});
}

/// @nodoc
class __$MessageListModelCopyWithImpl<$Res>
    implements _$MessageListModelCopyWith<$Res> {
  __$MessageListModelCopyWithImpl(this._self, this._then);

  final _MessageListModel _self;
  final $Res Function(_MessageListModel) _then;

  /// Create a copy of MessageListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? messages = null,
    Object? total = null,
    Object? page = null,
    Object? size = null,
  }) {
    return _then(_MessageListModel(
      messages: null == messages
          ? _self._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<MessageModel>,
      total: null == total
          ? _self.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _self.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      size: null == size
          ? _self.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
