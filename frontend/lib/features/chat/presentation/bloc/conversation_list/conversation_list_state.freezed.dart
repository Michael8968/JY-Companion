// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConversationListState {

 List<Conversation> get conversations; bool get isLoading; bool get isCreating; String? get errorMessage; String? get createdConversationId;
/// Create a copy of ConversationListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationListStateCopyWith<ConversationListState> get copyWith => _$ConversationListStateCopyWithImpl<ConversationListState>(this as ConversationListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationListState&&const DeepCollectionEquality().equals(other.conversations, conversations)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isCreating, isCreating) || other.isCreating == isCreating)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.createdConversationId, createdConversationId) || other.createdConversationId == createdConversationId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(conversations),isLoading,isCreating,errorMessage,createdConversationId);

@override
String toString() {
  return 'ConversationListState(conversations: $conversations, isLoading: $isLoading, isCreating: $isCreating, errorMessage: $errorMessage, createdConversationId: $createdConversationId)';
}


}

/// @nodoc
abstract mixin class $ConversationListStateCopyWith<$Res>  {
  factory $ConversationListStateCopyWith(ConversationListState value, $Res Function(ConversationListState) _then) = _$ConversationListStateCopyWithImpl;
@useResult
$Res call({
 List<Conversation> conversations, bool isLoading, bool isCreating, String? errorMessage, String? createdConversationId
});




}
/// @nodoc
class _$ConversationListStateCopyWithImpl<$Res>
    implements $ConversationListStateCopyWith<$Res> {
  _$ConversationListStateCopyWithImpl(this._self, this._then);

  final ConversationListState _self;
  final $Res Function(ConversationListState) _then;

/// Create a copy of ConversationListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversations = null,Object? isLoading = null,Object? isCreating = null,Object? errorMessage = freezed,Object? createdConversationId = freezed,}) {
  return _then(_self.copyWith(
conversations: null == conversations ? _self.conversations : conversations // ignore: cast_nullable_to_non_nullable
as List<Conversation>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isCreating: null == isCreating ? _self.isCreating : isCreating // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,createdConversationId: freezed == createdConversationId ? _self.createdConversationId : createdConversationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConversationListState].
extension ConversationListStatePatterns on ConversationListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationListState value)  $default,){
final _that = this;
switch (_that) {
case _ConversationListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationListState value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Conversation> conversations,  bool isLoading,  bool isCreating,  String? errorMessage,  String? createdConversationId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationListState() when $default != null:
return $default(_that.conversations,_that.isLoading,_that.isCreating,_that.errorMessage,_that.createdConversationId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Conversation> conversations,  bool isLoading,  bool isCreating,  String? errorMessage,  String? createdConversationId)  $default,) {final _that = this;
switch (_that) {
case _ConversationListState():
return $default(_that.conversations,_that.isLoading,_that.isCreating,_that.errorMessage,_that.createdConversationId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Conversation> conversations,  bool isLoading,  bool isCreating,  String? errorMessage,  String? createdConversationId)?  $default,) {final _that = this;
switch (_that) {
case _ConversationListState() when $default != null:
return $default(_that.conversations,_that.isLoading,_that.isCreating,_that.errorMessage,_that.createdConversationId);case _:
  return null;

}
}

}

/// @nodoc


class _ConversationListState implements ConversationListState {
  const _ConversationListState({final  List<Conversation> conversations = const [], this.isLoading = false, this.isCreating = false, this.errorMessage, this.createdConversationId}): _conversations = conversations;
  

 final  List<Conversation> _conversations;
@override@JsonKey() List<Conversation> get conversations {
  if (_conversations is EqualUnmodifiableListView) return _conversations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conversations);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isCreating;
@override final  String? errorMessage;
@override final  String? createdConversationId;

/// Create a copy of ConversationListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationListStateCopyWith<_ConversationListState> get copyWith => __$ConversationListStateCopyWithImpl<_ConversationListState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationListState&&const DeepCollectionEquality().equals(other._conversations, _conversations)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isCreating, isCreating) || other.isCreating == isCreating)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.createdConversationId, createdConversationId) || other.createdConversationId == createdConversationId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_conversations),isLoading,isCreating,errorMessage,createdConversationId);

@override
String toString() {
  return 'ConversationListState(conversations: $conversations, isLoading: $isLoading, isCreating: $isCreating, errorMessage: $errorMessage, createdConversationId: $createdConversationId)';
}


}

/// @nodoc
abstract mixin class _$ConversationListStateCopyWith<$Res> implements $ConversationListStateCopyWith<$Res> {
  factory _$ConversationListStateCopyWith(_ConversationListState value, $Res Function(_ConversationListState) _then) = __$ConversationListStateCopyWithImpl;
@override @useResult
$Res call({
 List<Conversation> conversations, bool isLoading, bool isCreating, String? errorMessage, String? createdConversationId
});




}
/// @nodoc
class __$ConversationListStateCopyWithImpl<$Res>
    implements _$ConversationListStateCopyWith<$Res> {
  __$ConversationListStateCopyWithImpl(this._self, this._then);

  final _ConversationListState _self;
  final $Res Function(_ConversationListState) _then;

/// Create a copy of ConversationListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversations = null,Object? isLoading = null,Object? isCreating = null,Object? errorMessage = freezed,Object? createdConversationId = freezed,}) {
  return _then(_ConversationListState(
conversations: null == conversations ? _self._conversations : conversations // ignore: cast_nullable_to_non_nullable
as List<Conversation>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isCreating: null == isCreating ? _self.isCreating : isCreating // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,createdConversationId: freezed == createdConversationId ? _self.createdConversationId : createdConversationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
