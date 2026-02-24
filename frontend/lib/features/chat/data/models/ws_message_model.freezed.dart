// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ws_message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WsIncomingMessage {

 String get type; String? get conversationId; String? get content; String? get contentType;
/// Create a copy of WsIncomingMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WsIncomingMessageCopyWith<WsIncomingMessage> get copyWith => _$WsIncomingMessageCopyWithImpl<WsIncomingMessage>(this as WsIncomingMessage, _$identity);

  /// Serializes this WsIncomingMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WsIncomingMessage&&(identical(other.type, type) || other.type == type)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.content, content) || other.content == content)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,conversationId,content,contentType);

@override
String toString() {
  return 'WsIncomingMessage(type: $type, conversationId: $conversationId, content: $content, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class $WsIncomingMessageCopyWith<$Res>  {
  factory $WsIncomingMessageCopyWith(WsIncomingMessage value, $Res Function(WsIncomingMessage) _then) = _$WsIncomingMessageCopyWithImpl;
@useResult
$Res call({
 String type, String? conversationId, String? content, String? contentType
});




}
/// @nodoc
class _$WsIncomingMessageCopyWithImpl<$Res>
    implements $WsIncomingMessageCopyWith<$Res> {
  _$WsIncomingMessageCopyWithImpl(this._self, this._then);

  final WsIncomingMessage _self;
  final $Res Function(WsIncomingMessage) _then;

/// Create a copy of WsIncomingMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? conversationId = freezed,Object? content = freezed,Object? contentType = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WsIncomingMessage].
extension WsIncomingMessagePatterns on WsIncomingMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WsIncomingMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WsIncomingMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WsIncomingMessage value)  $default,){
final _that = this;
switch (_that) {
case _WsIncomingMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WsIncomingMessage value)?  $default,){
final _that = this;
switch (_that) {
case _WsIncomingMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String? conversationId,  String? content,  String? contentType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WsIncomingMessage() when $default != null:
return $default(_that.type,_that.conversationId,_that.content,_that.contentType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String? conversationId,  String? content,  String? contentType)  $default,) {final _that = this;
switch (_that) {
case _WsIncomingMessage():
return $default(_that.type,_that.conversationId,_that.content,_that.contentType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String? conversationId,  String? content,  String? contentType)?  $default,) {final _that = this;
switch (_that) {
case _WsIncomingMessage() when $default != null:
return $default(_that.type,_that.conversationId,_that.content,_that.contentType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WsIncomingMessage implements WsIncomingMessage {
  const _WsIncomingMessage({required this.type, this.conversationId, this.content, this.contentType = 'text'});
  factory _WsIncomingMessage.fromJson(Map<String, dynamic> json) => _$WsIncomingMessageFromJson(json);

@override final  String type;
@override final  String? conversationId;
@override final  String? content;
@override@JsonKey() final  String? contentType;

/// Create a copy of WsIncomingMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WsIncomingMessageCopyWith<_WsIncomingMessage> get copyWith => __$WsIncomingMessageCopyWithImpl<_WsIncomingMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WsIncomingMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WsIncomingMessage&&(identical(other.type, type) || other.type == type)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.content, content) || other.content == content)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,conversationId,content,contentType);

@override
String toString() {
  return 'WsIncomingMessage(type: $type, conversationId: $conversationId, content: $content, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class _$WsIncomingMessageCopyWith<$Res> implements $WsIncomingMessageCopyWith<$Res> {
  factory _$WsIncomingMessageCopyWith(_WsIncomingMessage value, $Res Function(_WsIncomingMessage) _then) = __$WsIncomingMessageCopyWithImpl;
@override @useResult
$Res call({
 String type, String? conversationId, String? content, String? contentType
});




}
/// @nodoc
class __$WsIncomingMessageCopyWithImpl<$Res>
    implements _$WsIncomingMessageCopyWith<$Res> {
  __$WsIncomingMessageCopyWithImpl(this._self, this._then);

  final _WsIncomingMessage _self;
  final $Res Function(_WsIncomingMessage) _then;

/// Create a copy of WsIncomingMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? conversationId = freezed,Object? content = freezed,Object? contentType = freezed,}) {
  return _then(_WsIncomingMessage(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$WsOutgoingMessage {

 String get type; Map<String, dynamic>? get data;
/// Create a copy of WsOutgoingMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WsOutgoingMessageCopyWith<WsOutgoingMessage> get copyWith => _$WsOutgoingMessageCopyWithImpl<WsOutgoingMessage>(this as WsOutgoingMessage, _$identity);

  /// Serializes this WsOutgoingMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WsOutgoingMessage&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'WsOutgoingMessage(type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class $WsOutgoingMessageCopyWith<$Res>  {
  factory $WsOutgoingMessageCopyWith(WsOutgoingMessage value, $Res Function(WsOutgoingMessage) _then) = _$WsOutgoingMessageCopyWithImpl;
@useResult
$Res call({
 String type, Map<String, dynamic>? data
});




}
/// @nodoc
class _$WsOutgoingMessageCopyWithImpl<$Res>
    implements $WsOutgoingMessageCopyWith<$Res> {
  _$WsOutgoingMessageCopyWithImpl(this._self, this._then);

  final WsOutgoingMessage _self;
  final $Res Function(WsOutgoingMessage) _then;

/// Create a copy of WsOutgoingMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? data = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [WsOutgoingMessage].
extension WsOutgoingMessagePatterns on WsOutgoingMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WsOutgoingMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WsOutgoingMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WsOutgoingMessage value)  $default,){
final _that = this;
switch (_that) {
case _WsOutgoingMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WsOutgoingMessage value)?  $default,){
final _that = this;
switch (_that) {
case _WsOutgoingMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  Map<String, dynamic>? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WsOutgoingMessage() when $default != null:
return $default(_that.type,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  Map<String, dynamic>? data)  $default,) {final _that = this;
switch (_that) {
case _WsOutgoingMessage():
return $default(_that.type,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  Map<String, dynamic>? data)?  $default,) {final _that = this;
switch (_that) {
case _WsOutgoingMessage() when $default != null:
return $default(_that.type,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WsOutgoingMessage implements WsOutgoingMessage {
  const _WsOutgoingMessage({required this.type, final  Map<String, dynamic>? data}): _data = data;
  factory _WsOutgoingMessage.fromJson(Map<String, dynamic> json) => _$WsOutgoingMessageFromJson(json);

@override final  String type;
 final  Map<String, dynamic>? _data;
@override Map<String, dynamic>? get data {
  final value = _data;
  if (value == null) return null;
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of WsOutgoingMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WsOutgoingMessageCopyWith<_WsOutgoingMessage> get copyWith => __$WsOutgoingMessageCopyWithImpl<_WsOutgoingMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WsOutgoingMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WsOutgoingMessage&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'WsOutgoingMessage(type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class _$WsOutgoingMessageCopyWith<$Res> implements $WsOutgoingMessageCopyWith<$Res> {
  factory _$WsOutgoingMessageCopyWith(_WsOutgoingMessage value, $Res Function(_WsOutgoingMessage) _then) = __$WsOutgoingMessageCopyWithImpl;
@override @useResult
$Res call({
 String type, Map<String, dynamic>? data
});




}
/// @nodoc
class __$WsOutgoingMessageCopyWithImpl<$Res>
    implements _$WsOutgoingMessageCopyWith<$Res> {
  __$WsOutgoingMessageCopyWithImpl(this._self, this._then);

  final _WsOutgoingMessage _self;
  final $Res Function(_WsOutgoingMessage) _then;

/// Create a copy of WsOutgoingMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? data = freezed,}) {
  return _then(_WsOutgoingMessage(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
