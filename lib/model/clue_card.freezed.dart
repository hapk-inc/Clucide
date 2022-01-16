// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'clue_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ClueCard _$ClueCardFromJson(Map<String, dynamic> json) {
  return _ClueCard.fromJson(json);
}

/// @nodoc
class _$ClueCardTearOff {
  const _$ClueCardTearOff();

  _ClueCard call(
      {required String name, required CardType type, String? occupiedBy}) {
    return _ClueCard(
      name: name,
      type: type,
      occupiedBy: occupiedBy,
    );
  }

  ClueCard fromJson(Map<String, Object?> json) {
    return ClueCard.fromJson(json);
  }
}

/// @nodoc
const $ClueCard = _$ClueCardTearOff();

/// @nodoc
mixin _$ClueCard {
  String get name => throw _privateConstructorUsedError;
  CardType get type => throw _privateConstructorUsedError;
  String? get occupiedBy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ClueCardCopyWith<ClueCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClueCardCopyWith<$Res> {
  factory $ClueCardCopyWith(ClueCard value, $Res Function(ClueCard) then) =
      _$ClueCardCopyWithImpl<$Res>;
  $Res call({String name, CardType type, String? occupiedBy});
}

/// @nodoc
class _$ClueCardCopyWithImpl<$Res> implements $ClueCardCopyWith<$Res> {
  _$ClueCardCopyWithImpl(this._value, this._then);

  final ClueCard _value;
  // ignore: unused_field
  final $Res Function(ClueCard) _then;

  @override
  $Res call({
    Object? name = freezed,
    Object? type = freezed,
    Object? occupiedBy = freezed,
  }) {
    return _then(_value.copyWith(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: type == freezed
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CardType,
      occupiedBy: occupiedBy == freezed
          ? _value.occupiedBy
          : occupiedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$ClueCardCopyWith<$Res> implements $ClueCardCopyWith<$Res> {
  factory _$ClueCardCopyWith(_ClueCard value, $Res Function(_ClueCard) then) =
      __$ClueCardCopyWithImpl<$Res>;
  @override
  $Res call({String name, CardType type, String? occupiedBy});
}

/// @nodoc
class __$ClueCardCopyWithImpl<$Res> extends _$ClueCardCopyWithImpl<$Res>
    implements _$ClueCardCopyWith<$Res> {
  __$ClueCardCopyWithImpl(_ClueCard _value, $Res Function(_ClueCard) _then)
      : super(_value, (v) => _then(v as _ClueCard));

  @override
  _ClueCard get _value => super._value as _ClueCard;

  @override
  $Res call({
    Object? name = freezed,
    Object? type = freezed,
    Object? occupiedBy = freezed,
  }) {
    return _then(_ClueCard(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: type == freezed
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CardType,
      occupiedBy: occupiedBy == freezed
          ? _value.occupiedBy
          : occupiedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _$_ClueCard with DiagnosticableTreeMixin implements _ClueCard {
  const _$_ClueCard({required this.name, required this.type, this.occupiedBy});

  factory _$_ClueCard.fromJson(Map<String, dynamic> json) =>
      _$$_ClueCardFromJson(json);

  @override
  final String name;
  @override
  final CardType type;
  @override
  final String? occupiedBy;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ClueCard(name: $name, type: $type, occupiedBy: $occupiedBy)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ClueCard'))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('occupiedBy', occupiedBy));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ClueCard &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.type, type) &&
            const DeepCollectionEquality()
                .equals(other.occupiedBy, occupiedBy));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(type),
      const DeepCollectionEquality().hash(occupiedBy));

  @JsonKey(ignore: true)
  @override
  _$ClueCardCopyWith<_ClueCard> get copyWith =>
      __$ClueCardCopyWithImpl<_ClueCard>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ClueCardToJson(this);
  }
}

abstract class _ClueCard implements ClueCard {
  const factory _ClueCard(
      {required String name,
      required CardType type,
      String? occupiedBy}) = _$_ClueCard;

  factory _ClueCard.fromJson(Map<String, dynamic> json) = _$_ClueCard.fromJson;

  @override
  String get name;
  @override
  CardType get type;
  @override
  String? get occupiedBy;
  @override
  @JsonKey(ignore: true)
  _$ClueCardCopyWith<_ClueCard> get copyWith =>
      throw _privateConstructorUsedError;
}
