// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatState {

/// The open conversation; null for a new chat that hasn't been sent yet.
 Conversation? get conversation;/// Oldest first.
 List<ChatMessage> get messages;/// Loading an existing conversation's messages.
 bool get isLoadingMessages;/// Loading the messages failed; shown with a Retry button.
 String? get loadError;/// The assistant message currently being generated, if any.
 String? get activeMessageId;
/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatStateCopyWith<ChatState> get copyWith => _$ChatStateCopyWithImpl<ChatState>(this as ChatState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatState&&(identical(other.conversation, conversation) || other.conversation == conversation)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.isLoadingMessages, isLoadingMessages) || other.isLoadingMessages == isLoadingMessages)&&(identical(other.loadError, loadError) || other.loadError == loadError)&&(identical(other.activeMessageId, activeMessageId) || other.activeMessageId == activeMessageId));
}


@override
int get hashCode => Object.hash(runtimeType,conversation,const DeepCollectionEquality().hash(messages),isLoadingMessages,loadError,activeMessageId);

@override
String toString() {
  return 'ChatState(conversation: $conversation, messages: $messages, isLoadingMessages: $isLoadingMessages, loadError: $loadError, activeMessageId: $activeMessageId)';
}


}

/// @nodoc
abstract mixin class $ChatStateCopyWith<$Res>  {
  factory $ChatStateCopyWith(ChatState value, $Res Function(ChatState) _then) = _$ChatStateCopyWithImpl;
@useResult
$Res call({
 Conversation? conversation, List<ChatMessage> messages, bool isLoadingMessages, String? loadError, String? activeMessageId
});


$ConversationCopyWith<$Res>? get conversation;

}
/// @nodoc
class _$ChatStateCopyWithImpl<$Res>
    implements $ChatStateCopyWith<$Res> {
  _$ChatStateCopyWithImpl(this._self, this._then);

  final ChatState _self;
  final $Res Function(ChatState) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversation = freezed,Object? messages = null,Object? isLoadingMessages = null,Object? loadError = freezed,Object? activeMessageId = freezed,}) {
  return _then(_self.copyWith(
conversation: freezed == conversation ? _self.conversation : conversation // ignore: cast_nullable_to_non_nullable
as Conversation?,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,isLoadingMessages: null == isLoadingMessages ? _self.isLoadingMessages : isLoadingMessages // ignore: cast_nullable_to_non_nullable
as bool,loadError: freezed == loadError ? _self.loadError : loadError // ignore: cast_nullable_to_non_nullable
as String?,activeMessageId: freezed == activeMessageId ? _self.activeMessageId : activeMessageId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ChatState
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


/// Adds pattern-matching-related methods to [ChatState].
extension ChatStatePatterns on ChatState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatState value)  $default,){
final _that = this;
switch (_that) {
case _ChatState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Conversation? conversation,  List<ChatMessage> messages,  bool isLoadingMessages,  String? loadError,  String? activeMessageId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatState() when $default != null:
return $default(_that.conversation,_that.messages,_that.isLoadingMessages,_that.loadError,_that.activeMessageId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Conversation? conversation,  List<ChatMessage> messages,  bool isLoadingMessages,  String? loadError,  String? activeMessageId)  $default,) {final _that = this;
switch (_that) {
case _ChatState():
return $default(_that.conversation,_that.messages,_that.isLoadingMessages,_that.loadError,_that.activeMessageId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Conversation? conversation,  List<ChatMessage> messages,  bool isLoadingMessages,  String? loadError,  String? activeMessageId)?  $default,) {final _that = this;
switch (_that) {
case _ChatState() when $default != null:
return $default(_that.conversation,_that.messages,_that.isLoadingMessages,_that.loadError,_that.activeMessageId);case _:
  return null;

}
}

}

/// @nodoc


class _ChatState extends ChatState {
  const _ChatState({this.conversation, final  List<ChatMessage> messages = const <ChatMessage>[], this.isLoadingMessages = false, this.loadError, this.activeMessageId}): _messages = messages,super._();
  

/// The open conversation; null for a new chat that hasn't been sent yet.
@override final  Conversation? conversation;
/// Oldest first.
 final  List<ChatMessage> _messages;
/// Oldest first.
@override@JsonKey() List<ChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

/// Loading an existing conversation's messages.
@override@JsonKey() final  bool isLoadingMessages;
/// Loading the messages failed; shown with a Retry button.
@override final  String? loadError;
/// The assistant message currently being generated, if any.
@override final  String? activeMessageId;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatStateCopyWith<_ChatState> get copyWith => __$ChatStateCopyWithImpl<_ChatState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatState&&(identical(other.conversation, conversation) || other.conversation == conversation)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.isLoadingMessages, isLoadingMessages) || other.isLoadingMessages == isLoadingMessages)&&(identical(other.loadError, loadError) || other.loadError == loadError)&&(identical(other.activeMessageId, activeMessageId) || other.activeMessageId == activeMessageId));
}


@override
int get hashCode => Object.hash(runtimeType,conversation,const DeepCollectionEquality().hash(_messages),isLoadingMessages,loadError,activeMessageId);

@override
String toString() {
  return 'ChatState(conversation: $conversation, messages: $messages, isLoadingMessages: $isLoadingMessages, loadError: $loadError, activeMessageId: $activeMessageId)';
}


}

/// @nodoc
abstract mixin class _$ChatStateCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory _$ChatStateCopyWith(_ChatState value, $Res Function(_ChatState) _then) = __$ChatStateCopyWithImpl;
@override @useResult
$Res call({
 Conversation? conversation, List<ChatMessage> messages, bool isLoadingMessages, String? loadError, String? activeMessageId
});


@override $ConversationCopyWith<$Res>? get conversation;

}
/// @nodoc
class __$ChatStateCopyWithImpl<$Res>
    implements _$ChatStateCopyWith<$Res> {
  __$ChatStateCopyWithImpl(this._self, this._then);

  final _ChatState _self;
  final $Res Function(_ChatState) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversation = freezed,Object? messages = null,Object? isLoadingMessages = null,Object? loadError = freezed,Object? activeMessageId = freezed,}) {
  return _then(_ChatState(
conversation: freezed == conversation ? _self.conversation : conversation // ignore: cast_nullable_to_non_nullable
as Conversation?,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,isLoadingMessages: null == isLoadingMessages ? _self.isLoadingMessages : isLoadingMessages // ignore: cast_nullable_to_non_nullable
as bool,loadError: freezed == loadError ? _self.loadError : loadError // ignore: cast_nullable_to_non_nullable
as String?,activeMessageId: freezed == activeMessageId ? _self.activeMessageId : activeMessageId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ChatState
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

// dart format on
