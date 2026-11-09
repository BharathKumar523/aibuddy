// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HealthStatus {

 String get status; String get db; String get version; double get uptime;
/// Create a copy of HealthStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthStatusCopyWith<HealthStatus> get copyWith => _$HealthStatusCopyWithImpl<HealthStatus>(this as HealthStatus, _$identity);

  /// Serializes this HealthStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthStatus&&(identical(other.status, status) || other.status == status)&&(identical(other.db, db) || other.db == db)&&(identical(other.version, version) || other.version == version)&&(identical(other.uptime, uptime) || other.uptime == uptime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,db,version,uptime);

@override
String toString() {
  return 'HealthStatus(status: $status, db: $db, version: $version, uptime: $uptime)';
}


}

/// @nodoc
abstract mixin class $HealthStatusCopyWith<$Res>  {
  factory $HealthStatusCopyWith(HealthStatus value, $Res Function(HealthStatus) _then) = _$HealthStatusCopyWithImpl;
@useResult
$Res call({
 String status, String db, String version, double uptime
});




}
/// @nodoc
class _$HealthStatusCopyWithImpl<$Res>
    implements $HealthStatusCopyWith<$Res> {
  _$HealthStatusCopyWithImpl(this._self, this._then);

  final HealthStatus _self;
  final $Res Function(HealthStatus) _then;

/// Create a copy of HealthStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? db = null,Object? version = null,Object? uptime = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,db: null == db ? _self.db : db // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,uptime: null == uptime ? _self.uptime : uptime // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthStatus].
extension HealthStatusPatterns on HealthStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthStatus value)  $default,){
final _that = this;
switch (_that) {
case _HealthStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthStatus value)?  $default,){
final _that = this;
switch (_that) {
case _HealthStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  String db,  String version,  double uptime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthStatus() when $default != null:
return $default(_that.status,_that.db,_that.version,_that.uptime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  String db,  String version,  double uptime)  $default,) {final _that = this;
switch (_that) {
case _HealthStatus():
return $default(_that.status,_that.db,_that.version,_that.uptime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  String db,  String version,  double uptime)?  $default,) {final _that = this;
switch (_that) {
case _HealthStatus() when $default != null:
return $default(_that.status,_that.db,_that.version,_that.uptime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthStatus extends HealthStatus {
  const _HealthStatus({this.status = 'unknown', this.db = 'unknown', this.version = 'unknown', this.uptime = 0.0}): super._();
  factory _HealthStatus.fromJson(Map<String, dynamic> json) => _$HealthStatusFromJson(json);

@override@JsonKey() final  String status;
@override@JsonKey() final  String db;
@override@JsonKey() final  String version;
@override@JsonKey() final  double uptime;

/// Create a copy of HealthStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthStatusCopyWith<_HealthStatus> get copyWith => __$HealthStatusCopyWithImpl<_HealthStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthStatus&&(identical(other.status, status) || other.status == status)&&(identical(other.db, db) || other.db == db)&&(identical(other.version, version) || other.version == version)&&(identical(other.uptime, uptime) || other.uptime == uptime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,db,version,uptime);

@override
String toString() {
  return 'HealthStatus(status: $status, db: $db, version: $version, uptime: $uptime)';
}


}

/// @nodoc
abstract mixin class _$HealthStatusCopyWith<$Res> implements $HealthStatusCopyWith<$Res> {
  factory _$HealthStatusCopyWith(_HealthStatus value, $Res Function(_HealthStatus) _then) = __$HealthStatusCopyWithImpl;
@override @useResult
$Res call({
 String status, String db, String version, double uptime
});




}
/// @nodoc
class __$HealthStatusCopyWithImpl<$Res>
    implements _$HealthStatusCopyWith<$Res> {
  __$HealthStatusCopyWithImpl(this._self, this._then);

  final _HealthStatus _self;
  final $Res Function(_HealthStatus) _then;

/// Create a copy of HealthStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? db = null,Object? version = null,Object? uptime = null,}) {
  return _then(_HealthStatus(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,db: null == db ? _self.db : db // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,uptime: null == uptime ? _self.uptime : uptime // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
