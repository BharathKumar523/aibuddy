// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_stream_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatStreamEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatStreamEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatStreamEvent()';
}


}

/// @nodoc
class $ChatStreamEventCopyWith<$Res>  {
$ChatStreamEventCopyWith(ChatStreamEvent _, $Res Function(ChatStreamEvent) __);
}


/// Adds pattern-matching-related methods to [ChatStreamEvent].
extension ChatStreamEventPatterns on ChatStreamEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChatStreamStarted value)?  started,TResult Function( ChatStreamDelta value)?  delta,TResult Function( ChatStreamCompleted value)?  completed,TResult Function( ChatStreamFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChatStreamStarted() when started != null:
return started(_that);case ChatStreamDelta() when delta != null:
return delta(_that);case ChatStreamCompleted() when completed != null:
return completed(_that);case ChatStreamFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChatStreamStarted value)  started,required TResult Function( ChatStreamDelta value)  delta,required TResult Function( ChatStreamCompleted value)  completed,required TResult Function( ChatStreamFailed value)  failed,}){
final _that = this;
switch (_that) {
case ChatStreamStarted():
return started(_that);case ChatStreamDelta():
return delta(_that);case ChatStreamCompleted():
return completed(_that);case ChatStreamFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChatStreamStarted value)?  started,TResult? Function( ChatStreamDelta value)?  delta,TResult? Function( ChatStreamCompleted value)?  completed,TResult? Function( ChatStreamFailed value)?  failed,}){
final _that = this;
switch (_that) {
case ChatStreamStarted() when started != null:
return started(_that);case ChatStreamDelta() when delta != null:
return delta(_that);case ChatStreamCompleted() when completed != null:
return completed(_that);case ChatStreamFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ChatMessage? userMessage,  String assistantMessageId)?  started,TResult Function( String messageId,  String text)?  delta,TResult Function( ChatMessage message,  Conversation? conversation)?  completed,TResult Function( MessageError error,  String? messageId,  bool retryable)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChatStreamStarted() when started != null:
return started(_that.userMessage,_that.assistantMessageId);case ChatStreamDelta() when delta != null:
return delta(_that.messageId,_that.text);case ChatStreamCompleted() when completed != null:
return completed(_that.message,_that.conversation);case ChatStreamFailed() when failed != null:
return failed(_that.error,_that.messageId,_that.retryable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ChatMessage? userMessage,  String assistantMessageId)  started,required TResult Function( String messageId,  String text)  delta,required TResult Function( ChatMessage message,  Conversation? conversation)  completed,required TResult Function( MessageError error,  String? messageId,  bool retryable)  failed,}) {final _that = this;
switch (_that) {
case ChatStreamStarted():
return started(_that.userMessage,_that.assistantMessageId);case ChatStreamDelta():
return delta(_that.messageId,_that.text);case ChatStreamCompleted():
return completed(_that.message,_that.conversation);case ChatStreamFailed():
return failed(_that.error,_that.messageId,_that.retryable);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ChatMessage? userMessage,  String assistantMessageId)?  started,TResult? Function( String messageId,  String text)?  delta,TResult? Function( ChatMessage message,  Conversation? conversation)?  completed,TResult? Function( MessageError error,  String? messageId,  bool retryable)?  failed,}) {final _that = this;
switch (_that) {
case ChatStreamStarted() when started != null:
return started(_that.userMessage,_that.assistantMessageId);case ChatStreamDelta() when delta != null:
return delta(_that.messageId,_that.text);case ChatStreamCompleted() when completed != null:
return completed(_that.message,_that.conversation);case ChatStreamFailed() when failed != null:
return failed(_that.error,_that.messageId,_that.retryable);case _:
  return null;

}
}

}

/// @nodoc


class ChatStreamStarted implements ChatStreamEvent {
  const ChatStreamStarted({this.userMessage, required this.assistantMessageId});
  

 final  ChatMessage? userMessage;
 final  String assistantMessageId;

/// Create a copy of ChatStreamEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatStreamStartedCopyWith<ChatStreamStarted> get copyWith => _$ChatStreamStartedCopyWithImpl<ChatStreamStarted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatStreamStarted&&(identical(other.userMessage, userMessage) || other.userMessage == userMessage)&&(identical(other.assistantMessageId, assistantMessageId) || other.assistantMessageId == assistantMessageId));
}


@override
int get hashCode => Object.hash(runtimeType,userMessage,assistantMessageId);

@override
String toString() {
  return 'ChatStreamEvent.started(userMessage: $userMessage, assistantMessageId: $assistantMessageId)';
}


}

/// @nodoc
abstract mixin class $ChatStreamStartedCopyWith<$Res> implements $ChatStreamEventCopyWith<$Res> {
  factory $ChatStreamStartedCopyWith(ChatStreamStarted value, $Res Function(ChatStreamStarted) _then) = _$ChatStreamStartedCopyWithImpl;
@useResult
$Res call({
 ChatMessage? userMessage, String assistantMessageId
});


$ChatMessageCopyWith<$Res>? get userMessage;

}
/// @nodoc
class _$ChatStreamStartedCopyWithImpl<$Res>
    implements $ChatStreamStartedCopyWith<$Res> {
  _$ChatStreamStartedCopyWithImpl(this._self, this._then);

  final ChatStreamStarted _self;
  final $Res Function(ChatStreamStarted) _then;

/// Create a copy of ChatStreamEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userMessage = freezed,Object? assistantMessageId = null,}) {
  return _then(ChatStreamStarted(
userMessage: freezed == userMessage ? _self.userMessage : userMessage // ignore: cast_nullable_to_non_nullable
as ChatMessage?,assistantMessageId: null == assistantMessageId ? _self.assistantMessageId : assistantMessageId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ChatStreamEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<$Res>? get userMessage {
    if (_self.userMessage == null) {
    return null;
  }

  return $ChatMessageCopyWith<$Res>(_self.userMessage!, (value) {
    return _then(_self.copyWith(userMessage: value));
  });
}
}

/// @nodoc


class ChatStreamDelta implements ChatStreamEvent {
  const ChatStreamDelta({required this.messageId, required this.text});
  

 final  String messageId;
 final  String text;

/// Create a copy of ChatStreamEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatStreamDeltaCopyWith<ChatStreamDelta> get copyWith => _$ChatStreamDeltaCopyWithImpl<ChatStreamDelta>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatStreamDelta&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,messageId,text);

@override
String toString() {
  return 'ChatStreamEvent.delta(messageId: $messageId, text: $text)';
}


}

/// @nodoc
abstract mixin class $ChatStreamDeltaCopyWith<$Res> implements $ChatStreamEventCopyWith<$Res> {
  factory $ChatStreamDeltaCopyWith(ChatStreamDelta value, $Res Function(ChatStreamDelta) _then) = _$ChatStreamDeltaCopyWithImpl;
@useResult
$Res call({
 String messageId, String text
});




}
/// @nodoc
class _$ChatStreamDeltaCopyWithImpl<$Res>
    implements $ChatStreamDeltaCopyWith<$Res> {
  _$ChatStreamDeltaCopyWithImpl(this._self, this._then);

  final ChatStreamDelta _self;
  final $Res Function(ChatStreamDelta) _then;

/// Create a copy of ChatStreamEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? messageId = null,Object? text = null,}) {
  return _then(ChatStreamDelta(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ChatStreamCompleted implements ChatStreamEvent {
  const ChatStreamCompleted({required this.message, this.conversation});
  

 final  ChatMessage message;
 final  Conversation? conversation;

/// Create a copy of ChatStreamEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatStreamCompletedCopyWith<ChatStreamCompleted> get copyWith => _$ChatStreamCompletedCopyWithImpl<ChatStreamCompleted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatStreamCompleted&&(identical(other.message, message) || other.message == message)&&(identical(other.conversation, conversation) || other.conversation == conversation));
}


@override
int get hashCode => Object.hash(runtimeType,message,conversation);

@override
String toString() {
  return 'ChatStreamEvent.completed(message: $message, conversation: $conversation)';
}


}

/// @nodoc
abstract mixin class $ChatStreamCompletedCopyWith<$Res> implements $ChatStreamEventCopyWith<$Res> {
  factory $ChatStreamCompletedCopyWith(ChatStreamCompleted value, $Res Function(ChatStreamCompleted) _then) = _$ChatStreamCompletedCopyWithImpl;
@useResult
$Res call({
 ChatMessage message, Conversation? conversation
});


$ChatMessageCopyWith<$Res> get message;$ConversationCopyWith<$Res>? get conversation;

}
/// @nodoc
class _$ChatStreamCompletedCopyWithImpl<$Res>
    implements $ChatStreamCompletedCopyWith<$Res> {
  _$ChatStreamCompletedCopyWithImpl(this._self, this._then);

  final ChatStreamCompleted _self;
  final $Res Function(ChatStreamCompleted) _then;

/// Create a copy of ChatStreamEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? conversation = freezed,}) {
  return _then(ChatStreamCompleted(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as ChatMessage,conversation: freezed == conversation ? _self.conversation : conversation // ignore: cast_nullable_to_non_nullable
as Conversation?,
  ));
}

/// Create a copy of ChatStreamEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<$Res> get message {
  
  return $ChatMessageCopyWith<$Res>(_self.message, (value) {
    return _then(_self.copyWith(message: value));
  });
}/// Create a copy of ChatStreamEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConversationCopyWith<$Res>? get conversation {
    if (_self.conversation == null) {
    return null;
  }

  return $ConversationCopyWith<$Res>(_self.conversation!, (value) {
    return _then(_self.copyWith(conversation: value));
  });
}
}

/// @nodoc


class ChatStreamFailed implements ChatStreamEvent {
  const ChatStreamFailed({required this.error, this.messageId, this.retryable = true});
  

 final  MessageError error;
 final  String? messageId;
@JsonKey() final  bool retryable;

/// Create a copy of ChatStreamEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatStreamFailedCopyWith<ChatStreamFailed> get copyWith => _$ChatStreamFailedCopyWithImpl<ChatStreamFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatStreamFailed&&(identical(other.error, error) || other.error == error)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.retryable, retryable) || other.retryable == retryable));
}


@override
int get hashCode => Object.hash(runtimeType,error,messageId,retryable);

@override
String toString() {
  return 'ChatStreamEvent.failed(error: $error, messageId: $messageId, retryable: $retryable)';
}


}

/// @nodoc
abstract mixin class $ChatStreamFailedCopyWith<$Res> implements $ChatStreamEventCopyWith<$Res> {
  factory $ChatStreamFailedCopyWith(ChatStreamFailed value, $Res Function(ChatStreamFailed) _then) = _$ChatStreamFailedCopyWithImpl;
@useResult
$Res call({
 MessageError error, String? messageId, bool retryable
});


$MessageErrorCopyWith<$Res> get error;

}
/// @nodoc
class _$ChatStreamFailedCopyWithImpl<$Res>
    implements $ChatStreamFailedCopyWith<$Res> {
  _$ChatStreamFailedCopyWithImpl(this._self, this._then);

  final ChatStreamFailed _self;
  final $Res Function(ChatStreamFailed) _then;

/// Create a copy of ChatStreamEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,Object? messageId = freezed,Object? retryable = null,}) {
  return _then(ChatStreamFailed(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as MessageError,messageId: freezed == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String?,retryable: null == retryable ? _self.retryable : retryable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ChatStreamEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageErrorCopyWith<$Res> get error {
  
  return $MessageErrorCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

// dart format on
