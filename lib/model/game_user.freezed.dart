// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'game_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

GameUser _$GameUserFromJson(Map<String, dynamic> json) {
  return _GameUser.fromJson(json);
}

/// @nodoc
class _$GameUserTearOff {
  const _$GameUserTearOff();

  _GameUser call({required String name}) {
    return _GameUser(
      name: name,
    );
  }

  GameUser fromJson(Map<String, Object?> json) {
    return GameUser.fromJson(json);
  }
}

/// @nodoc
const $GameUser = _$GameUserTearOff();

/// @nodoc
mixin _$GameUser {
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GameUserCopyWith<GameUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameUserCopyWith<$Res> {
  factory $GameUserCopyWith(GameUser value, $Res Function(GameUser) then) =
      _$GameUserCopyWithImpl<$Res>;
  $Res call({String name});
}

/// @nodoc
class _$GameUserCopyWithImpl<$Res> implements $GameUserCopyWith<$Res> {
  _$GameUserCopyWithImpl(this._value, this._then);

  final GameUser _value;
  // ignore: unused_field
  final $Res Function(GameUser) _then;

  @override
  $Res call({
    Object? name = freezed,
  }) {
    return _then(_value.copyWith(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$GameUserCopyWith<$Res> implements $GameUserCopyWith<$Res> {
  factory _$GameUserCopyWith(_GameUser value, $Res Function(_GameUser) then) =
      __$GameUserCopyWithImpl<$Res>;
  @override
  $Res call({String name});
}

/// @nodoc
class __$GameUserCopyWithImpl<$Res> extends _$GameUserCopyWithImpl<$Res>
    implements _$GameUserCopyWith<$Res> {
  __$GameUserCopyWithImpl(_GameUser _value, $Res Function(_GameUser) _then)
      : super(_value, (v) => _then(v as _GameUser));

  @override
  _GameUser get _value => super._value as _GameUser;

  @override
  $Res call({
    Object? name = freezed,
  }) {
    return _then(_GameUser(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _$_GameUser with DiagnosticableTreeMixin implements _GameUser {
  const _$_GameUser({required this.name});

  factory _$_GameUser.fromJson(Map<String, dynamic> json) =>
      _$$_GameUserFromJson(json);

  @override
  final String name;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GameUser(name: $name)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GameUser'))
      ..add(DiagnosticsProperty('name', name));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GameUser &&
            const DeepCollectionEquality().equals(other.name, name));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(name));

  @JsonKey(ignore: true)
  @override
  _$GameUserCopyWith<_GameUser> get copyWith =>
      __$GameUserCopyWithImpl<_GameUser>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GameUserToJson(this);
  }
}

abstract class _GameUser implements GameUser {
  const factory _GameUser({required String name}) = _$_GameUser;

  factory _GameUser.fromJson(Map<String, dynamic> json) = _$_GameUser.fromJson;

  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$GameUserCopyWith<_GameUser> get copyWith =>
      throw _privateConstructorUsedError;
}
