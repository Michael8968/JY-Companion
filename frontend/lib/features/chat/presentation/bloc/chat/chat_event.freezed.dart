// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatEvent()';
}


}

/// @nodoc
class $ChatEventCopyWith<$Res>  {
$ChatEventCopyWith(ChatEvent _, $Res Function(ChatEvent) __);
}


/// Adds pattern-matching-related methods to [ChatEvent].
extension ChatEventPatterns on ChatEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _EnterChat value)?  enterChat,TResult Function( _LeaveChat value)?  leaveChat,TResult Function( _SendMessage value)?  sendMessage,TResult Function( _LoadMoreMessages value)?  loadMoreMessages,TResult Function( _WsMessageReceived value)?  wsMessageReceived,TResult Function( _WsConnectionChanged value)?  wsConnectionChanged,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnterChat() when enterChat != null:
return enterChat(_that);case _LeaveChat() when leaveChat != null:
return leaveChat(_that);case _SendMessage() when sendMessage != null:
return sendMessage(_that);case _LoadMoreMessages() when loadMoreMessages != null:
return loadMoreMessages(_that);case _WsMessageReceived() when wsMessageReceived != null:
return wsMessageReceived(_that);case _WsConnectionChanged() when wsConnectionChanged != null:
return wsConnectionChanged(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _EnterChat value)  enterChat,required TResult Function( _LeaveChat value)  leaveChat,required TResult Function( _SendMessage value)  sendMessage,required TResult Function( _LoadMoreMessages value)  loadMoreMessages,required TResult Function( _WsMessageReceived value)  wsMessageReceived,required TResult Function( _WsConnectionChanged value)  wsConnectionChanged,}){
final _that = this;
switch (_that) {
case _EnterChat():
return enterChat(_that);case _LeaveChat():
return leaveChat(_that);case _SendMessage():
return sendMessage(_that);case _LoadMoreMessages():
return loadMoreMessages(_that);case _WsMessageReceived():
return wsMessageReceived(_that);case _WsConnectionChanged():
return wsConnectionChanged(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _EnterChat value)?  enterChat,TResult? Function( _LeaveChat value)?  leaveChat,TResult? Function( _SendMessage value)?  sendMessage,TResult? Function( _LoadMoreMessages value)?  loadMoreMessages,TResult? Function( _WsMessageReceived value)?  wsMessageReceived,TResult? Function( _WsConnectionChanged value)?  wsConnectionChanged,}){
final _that = this;
switch (_that) {
case _EnterChat() when enterChat != null:
return enterChat(_that);case _LeaveChat() when leaveChat != null:
return leaveChat(_that);case _SendMessage() when sendMessage != null:
return sendMessage(_that);case _LoadMoreMessages() when loadMoreMessages != null:
return loadMoreMessages(_that);case _WsMessageReceived() when wsMessageReceived != null:
return wsMessageReceived(_that);case _WsConnectionChanged() when wsConnectionChanged != null:
return wsConnectionChanged(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String conversationId)?  enterChat,TResult Function()?  leaveChat,TResult Function( String content)?  sendMessage,TResult Function()?  loadMoreMessages,TResult Function( WsOutgoingMessage message)?  wsMessageReceived,TResult Function( bool connected)?  wsConnectionChanged,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnterChat() when enterChat != null:
return enterChat(_that.conversationId);case _LeaveChat() when leaveChat != null:
return leaveChat();case _SendMessage() when sendMessage != null:
return sendMessage(_that.content);case _LoadMoreMessages() when loadMoreMessages != null:
return loadMoreMessages();case _WsMessageReceived() when wsMessageReceived != null:
return wsMessageReceived(_that.message);case _WsConnectionChanged() when wsConnectionChanged != null:
return wsConnectionChanged(_that.connected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String conversationId)  enterChat,required TResult Function()  leaveChat,required TResult Function( String content)  sendMessage,required TResult Function()  loadMoreMessages,required TResult Function( WsOutgoingMessage message)  wsMessageReceived,required TResult Function( bool connected)  wsConnectionChanged,}) {final _that = this;
switch (_that) {
case _EnterChat():
return enterChat(_that.conversationId);case _LeaveChat():
return leaveChat();case _SendMessage():
return sendMessage(_that.content);case _LoadMoreMessages():
return loadMoreMessages();case _WsMessageReceived():
return wsMessageReceived(_that.message);case _WsConnectionChanged():
return wsConnectionChanged(_that.connected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String conversationId)?  enterChat,TResult? Function()?  leaveChat,TResult? Function( String content)?  sendMessage,TResult? Function()?  loadMoreMessages,TResult? Function( WsOutgoingMessage message)?  wsMessageReceived,TResult? Function( bool connected)?  wsConnectionChanged,}) {final _that = this;
switch (_that) {
case _EnterChat() when enterChat != null:
return enterChat(_that.conversationId);case _LeaveChat() when leaveChat != null:
return leaveChat();case _SendMessage() when sendMessage != null:
return sendMessage(_that.content);case _LoadMoreMessages() when loadMoreMessages != null:
return loadMoreMessages();case _WsMessageReceived() when wsMessageReceived != null:
return wsMessageReceived(_that.message);case _WsConnectionChanged() when wsConnectionChanged != null:
return wsConnectionChanged(_that.connected);case _:
  return null;

}
}

}

/// @nodoc


class _EnterChat implements ChatEvent {
  const _EnterChat(this.conversationId);
  

 final  String conversationId;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnterChatCopyWith<_EnterChat> get copyWith => __$EnterChatCopyWithImpl<_EnterChat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnterChat&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId);

@override
String toString() {
  return 'ChatEvent.enterChat(conversationId: $conversationId)';
}


}

/// @nodoc
abstract mixin class _$EnterChatCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory _$EnterChatCopyWith(_EnterChat value, $Res Function(_EnterChat) _then) = __$EnterChatCopyWithImpl;
@useResult
$Res call({
 String conversationId
});




}
/// @nodoc
class __$EnterChatCopyWithImpl<$Res>
    implements _$EnterChatCopyWith<$Res> {
  __$EnterChatCopyWithImpl(this._self, this._then);

  final _EnterChat _self;
  final $Res Function(_EnterChat) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversationId = null,}) {
  return _then(_EnterChat(
null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _LeaveChat implements ChatEvent {
  const _LeaveChat();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveChat);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatEvent.leaveChat()';
}


}




/// @nodoc


class _SendMessage implements ChatEvent {
  const _SendMessage(this.content);
  

 final  String content;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendMessageCopyWith<_SendMessage> get copyWith => __$SendMessageCopyWithImpl<_SendMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendMessage&&(identical(other.content, content) || other.content == content));
}


@override
int get hashCode => Object.hash(runtimeType,content);

@override
String toString() {
  return 'ChatEvent.sendMessage(content: $content)';
}


}

/// @nodoc
abstract mixin class _$SendMessageCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory _$SendMessageCopyWith(_SendMessage value, $Res Function(_SendMessage) _then) = __$SendMessageCopyWithImpl;
@useResult
$Res call({
 String content
});




}
/// @nodoc
class __$SendMessageCopyWithImpl<$Res>
    implements _$SendMessageCopyWith<$Res> {
  __$SendMessageCopyWithImpl(this._self, this._then);

  final _SendMessage _self;
  final $Res Function(_SendMessage) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? content = null,}) {
  return _then(_SendMessage(
null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _LoadMoreMessages implements ChatEvent {
  const _LoadMoreMessages();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadMoreMessages);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatEvent.loadMoreMessages()';
}


}




/// @nodoc


class _WsMessageReceived implements ChatEvent {
  const _WsMessageReceived(this.message);
  

 final  WsOutgoingMessage message;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WsMessageReceivedCopyWith<_WsMessageReceived> get copyWith => __$WsMessageReceivedCopyWithImpl<_WsMessageReceived>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WsMessageReceived&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ChatEvent.wsMessageReceived(message: $message)';
}


}

/// @nodoc
abstract mixin class _$WsMessageReceivedCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory _$WsMessageReceivedCopyWith(_WsMessageReceived value, $Res Function(_WsMessageReceived) _then) = __$WsMessageReceivedCopyWithImpl;
@useResult
$Res call({
 WsOutgoingMessage message
});


$WsOutgoingMessageCopyWith<$Res> get message;

}
/// @nodoc
class __$WsMessageReceivedCopyWithImpl<$Res>
    implements _$WsMessageReceivedCopyWith<$Res> {
  __$WsMessageReceivedCopyWithImpl(this._self, this._then);

  final _WsMessageReceived _self;
  final $Res Function(_WsMessageReceived) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_WsMessageReceived(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as WsOutgoingMessage,
  ));
}

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WsOutgoingMessageCopyWith<$Res> get message {
  
  return $WsOutgoingMessageCopyWith<$Res>(_self.message, (value) {
    return _then(_self.copyWith(message: value));
  });
}
}

/// @nodoc


class _WsConnectionChanged implements ChatEvent {
  const _WsConnectionChanged(this.connected);
  

 final  bool connected;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WsConnectionChangedCopyWith<_WsConnectionChanged> get copyWith => __$WsConnectionChangedCopyWithImpl<_WsConnectionChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WsConnectionChanged&&(identical(other.connected, connected) || other.connected == connected));
}


@override
int get hashCode => Object.hash(runtimeType,connected);

@override
String toString() {
  return 'ChatEvent.wsConnectionChanged(connected: $connected)';
}


}

/// @nodoc
abstract mixin class _$WsConnectionChangedCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory _$WsConnectionChangedCopyWith(_WsConnectionChanged value, $Res Function(_WsConnectionChanged) _then) = __$WsConnectionChangedCopyWithImpl;
@useResult
$Res call({
 bool connected
});




}
/// @nodoc
class __$WsConnectionChangedCopyWithImpl<$Res>
    implements _$WsConnectionChangedCopyWith<$Res> {
  __$WsConnectionChangedCopyWithImpl(this._self, this._then);

  final _WsConnectionChanged _self;
  final $Res Function(_WsConnectionChanged) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? connected = null,}) {
  return _then(_WsConnectionChanged(
null == connected ? _self.connected : connected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
