// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'player.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Player _$PlayerFromJson(Map<String, dynamic> json) {
  return _Player.fromJson(json);
}

/// @nodoc
class _$PlayerTearOff {
  const _$PlayerTearOff();

  _Player call(
      {required String as,
      required String name,
      bool isActive = true,
      required int playerNo,
      required int cardCount,
      required List<String> clues}) {
    return _Player(
      as: as,
      name: name,
      isActive: isActive,
      playerNo: playerNo,
      cardCount: cardCount,
      clues: clues,
    );
  }

  Player fromJson(Map<String, Object?> json) {
    return Player.fromJson(json);
  }
}

/// @nodoc
const $Player = _$PlayerTearOff();

/// @nodoc
mixin _$Player {
  String get as => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  int get playerNo => throw _privateConstructorUsedError;
  int get cardCount => throw _privateConstructorUsedError;
  List<String> get clues => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlayerCopyWith<Player> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerCopyWith<$Res> {
  factory $PlayerCopyWith(Player value, $Res Function(Player) then) =
      _$PlayerCopyWithImpl<$Res>;
  $Res call(
      {String as,
      String name,
      bool isActive,
      int playerNo,
      int cardCount,
      List<String> clues});
}

/// @nodoc
class _$PlayerCopyWithImpl<$Res> implements $PlayerCopyWith<$Res> {
  _$PlayerCopyWithImpl(this._value, this._then);

  final Player _value;
  // ignore: unused_field
  final $Res Function(Player) _then;

  @override
  $Res call({
    Object? as = freezed,
    Object? name = freezed,
    Object? isActive = freezed,
    Object? playerNo = freezed,
    Object? cardCount = freezed,
    Object? clues = freezed,
  }) {
    return _then(_value.copyWith(
      as: as == freezed
          ? _value.as
          : as // ignore: cast_nullable_to_non_nullable
              as String,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: isActive == freezed
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      playerNo: playerNo == freezed
          ? _value.playerNo
          : playerNo // ignore: cast_nullable_to_non_nullable
              as int,
      cardCount: cardCount == freezed
          ? _value.cardCount
          : cardCount // ignore: cast_nullable_to_non_nullable
              as int,
      clues: clues == freezed
          ? _value.clues
          : clues // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
abstract class _$PlayerCopyWith<$Res> implements $PlayerCopyWith<$Res> {
  factory _$PlayerCopyWith(_Player value, $Res Function(_Player) then) =
      __$PlayerCopyWithImpl<$Res>;
  @override
  $Res call(
      {String as,
      String name,
      bool isActive,
      int playerNo,
      int cardCount,
      List<String> clues});
}

/// @nodoc
class __$PlayerCopyWithImpl<$Res> extends _$PlayerCopyWithImpl<$Res>
    implements _$PlayerCopyWith<$Res> {
  __$PlayerCopyWithImpl(_Player _value, $Res Function(_Player) _then)
      : super(_value, (v) => _then(v as _Player));

  @override
  _Player get _value => super._value as _Player;

  @override
  $Res call({
    Object? as = freezed,
    Object? name = freezed,
    Object? isActive = freezed,
    Object? playerNo = freezed,
    Object? cardCount = freezed,
    Object? clues = freezed,
  }) {
    return _then(_Player(
      as: as == freezed
          ? _value.as
          : as // ignore: cast_nullable_to_non_nullable
              as String,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: isActive == freezed
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      playerNo: playerNo == freezed
          ? _value.playerNo
          : playerNo // ignore: cast_nullable_to_non_nullable
              as int,
      cardCount: cardCount == freezed
          ? _value.cardCount
          : cardCount // ignore: cast_nullable_to_non_nullable
              as int,
      clues: clues == freezed
          ? _value.clues
          : clues // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _$_Player with DiagnosticableTreeMixin implements _Player {
  const _$_Player(
      {required this.as,
      required this.name,
      this.isActive = true,
      required this.playerNo,
      required this.cardCount,
      required this.clues});

  factory _$_Player.fromJson(Map<String, dynamic> json) =>
      _$$_PlayerFromJson(json);

  @override
  final String as;
  @override
  final String name;
  @JsonKey()
  @override
  final bool isActive;
  @override
  final int playerNo;
  @override
  final int cardCount;
  @override
  final List<String> clues;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Player(as: $as, name: $name, isActive: $isActive, playerNo: $playerNo, cardCount: $cardCount, clues: $clues)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Player'))
      ..add(DiagnosticsProperty('as', as))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('isActive', isActive))
      ..add(DiagnosticsProperty('playerNo', playerNo))
      ..add(DiagnosticsProperty('cardCount', cardCount))
      ..add(DiagnosticsProperty('clues', clues));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Player &&
            const DeepCollectionEquality().equals(other.as, as) &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.isActive, isActive) &&
            const DeepCollectionEquality().equals(other.playerNo, playerNo) &&
            const DeepCollectionEquality().equals(other.cardCount, cardCount) &&
            const DeepCollectionEquality().equals(other.clues, clues));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(as),
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(isActive),
      const DeepCollectionEquality().hash(playerNo),
      const DeepCollectionEquality().hash(cardCount),
      const DeepCollectionEquality().hash(clues));

  @JsonKey(ignore: true)
  @override
  _$PlayerCopyWith<_Player> get copyWith =>
      __$PlayerCopyWithImpl<_Player>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PlayerToJson(this);
  }
}

abstract class _Player implements Player {
  const factory _Player(
      {required String as,
      required String name,
      bool isActive,
      required int playerNo,
      required int cardCount,
      required List<String> clues}) = _$_Player;

  factory _Player.fromJson(Map<String, dynamic> json) = _$_Player.fromJson;

  @override
  String get as;
  @override
  String get name;
  @override
  bool get isActive;
  @override
  int get playerNo;
  @override
  int get cardCount;
  @override
  List<String> get clues;
  @override
  @JsonKey(ignore: true)
  _$PlayerCopyWith<_Player> get copyWith => throw _privateConstructorUsedError;
}
