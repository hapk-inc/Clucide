// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'round.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Round _$RoundFromJson(Map<String, dynamic> json) {
  return _Round.fromJson(json);
}

/// @nodoc
class _$RoundTearOff {
  const _$RoundTearOff();

  _Round call(
      {required String asking,
      String? to,
      required List<String> clues,
      required String place,
      Map<String, bool?> answers = const {},
      String? roundAnswer,
      bool? accusing}) {
    return _Round(
      asking: asking,
      to: to,
      clues: clues,
      place: place,
      answers: answers,
      roundAnswer: roundAnswer,
      accusing: accusing,
    );
  }

  Round fromJson(Map<String, Object?> json) {
    return Round.fromJson(json);
  }
}

/// @nodoc
const $Round = _$RoundTearOff();

/// @nodoc
mixin _$Round {
  String get asking => throw _privateConstructorUsedError;
  String? get to => throw _privateConstructorUsedError;
  List<String> get clues => throw _privateConstructorUsedError;
  String get place => throw _privateConstructorUsedError;
  Map<String, bool?> get answers => throw _privateConstructorUsedError;
  String? get roundAnswer => throw _privateConstructorUsedError;
  bool? get accusing => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RoundCopyWith<Round> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoundCopyWith<$Res> {
  factory $RoundCopyWith(Round value, $Res Function(Round) then) =
      _$RoundCopyWithImpl<$Res>;
  $Res call(
      {String asking,
      String? to,
      List<String> clues,
      String place,
      Map<String, bool?> answers,
      String? roundAnswer,
      bool? accusing});
}

/// @nodoc
class _$RoundCopyWithImpl<$Res> implements $RoundCopyWith<$Res> {
  _$RoundCopyWithImpl(this._value, this._then);

  final Round _value;
  // ignore: unused_field
  final $Res Function(Round) _then;

  @override
  $Res call({
    Object? asking = freezed,
    Object? to = freezed,
    Object? clues = freezed,
    Object? place = freezed,
    Object? answers = freezed,
    Object? roundAnswer = freezed,
    Object? accusing = freezed,
  }) {
    return _then(_value.copyWith(
      asking: asking == freezed
          ? _value.asking
          : asking // ignore: cast_nullable_to_non_nullable
              as String,
      to: to == freezed
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as String?,
      clues: clues == freezed
          ? _value.clues
          : clues // ignore: cast_nullable_to_non_nullable
              as List<String>,
      place: place == freezed
          ? _value.place
          : place // ignore: cast_nullable_to_non_nullable
              as String,
      answers: answers == freezed
          ? _value.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, bool?>,
      roundAnswer: roundAnswer == freezed
          ? _value.roundAnswer
          : roundAnswer // ignore: cast_nullable_to_non_nullable
              as String?,
      accusing: accusing == freezed
          ? _value.accusing
          : accusing // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
abstract class _$RoundCopyWith<$Res> implements $RoundCopyWith<$Res> {
  factory _$RoundCopyWith(_Round value, $Res Function(_Round) then) =
      __$RoundCopyWithImpl<$Res>;
  @override
  $Res call(
      {String asking,
      String? to,
      List<String> clues,
      String place,
      Map<String, bool?> answers,
      String? roundAnswer,
      bool? accusing});
}

/// @nodoc
class __$RoundCopyWithImpl<$Res> extends _$RoundCopyWithImpl<$Res>
    implements _$RoundCopyWith<$Res> {
  __$RoundCopyWithImpl(_Round _value, $Res Function(_Round) _then)
      : super(_value, (v) => _then(v as _Round));

  @override
  _Round get _value => super._value as _Round;

  @override
  $Res call({
    Object? asking = freezed,
    Object? to = freezed,
    Object? clues = freezed,
    Object? place = freezed,
    Object? answers = freezed,
    Object? roundAnswer = freezed,
    Object? accusing = freezed,
  }) {
    return _then(_Round(
      asking: asking == freezed
          ? _value.asking
          : asking // ignore: cast_nullable_to_non_nullable
              as String,
      to: to == freezed
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as String?,
      clues: clues == freezed
          ? _value.clues
          : clues // ignore: cast_nullable_to_non_nullable
              as List<String>,
      place: place == freezed
          ? _value.place
          : place // ignore: cast_nullable_to_non_nullable
              as String,
      answers: answers == freezed
          ? _value.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, bool?>,
      roundAnswer: roundAnswer == freezed
          ? _value.roundAnswer
          : roundAnswer // ignore: cast_nullable_to_non_nullable
              as String?,
      accusing: accusing == freezed
          ? _value.accusing
          : accusing // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _$_Round with DiagnosticableTreeMixin implements _Round {
  const _$_Round(
      {required this.asking,
      this.to,
      required this.clues,
      required this.place,
      this.answers = const {},
      this.roundAnswer,
      this.accusing});

  factory _$_Round.fromJson(Map<String, dynamic> json) =>
      _$$_RoundFromJson(json);

  @override
  final String asking;
  @override
  final String? to;
  @override
  final List<String> clues;
  @override
  final String place;
  @JsonKey()
  @override
  final Map<String, bool?> answers;
  @override
  final String? roundAnswer;
  @override
  final bool? accusing;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Round(asking: $asking, to: $to, clues: $clues, place: $place, answers: $answers, roundAnswer: $roundAnswer, accusing: $accusing)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Round'))
      ..add(DiagnosticsProperty('asking', asking))
      ..add(DiagnosticsProperty('to', to))
      ..add(DiagnosticsProperty('clues', clues))
      ..add(DiagnosticsProperty('place', place))
      ..add(DiagnosticsProperty('answers', answers))
      ..add(DiagnosticsProperty('roundAnswer', roundAnswer))
      ..add(DiagnosticsProperty('accusing', accusing));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Round &&
            const DeepCollectionEquality().equals(other.asking, asking) &&
            const DeepCollectionEquality().equals(other.to, to) &&
            const DeepCollectionEquality().equals(other.clues, clues) &&
            const DeepCollectionEquality().equals(other.place, place) &&
            const DeepCollectionEquality().equals(other.answers, answers) &&
            const DeepCollectionEquality()
                .equals(other.roundAnswer, roundAnswer) &&
            const DeepCollectionEquality().equals(other.accusing, accusing));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(asking),
      const DeepCollectionEquality().hash(to),
      const DeepCollectionEquality().hash(clues),
      const DeepCollectionEquality().hash(place),
      const DeepCollectionEquality().hash(answers),
      const DeepCollectionEquality().hash(roundAnswer),
      const DeepCollectionEquality().hash(accusing));

  @JsonKey(ignore: true)
  @override
  _$RoundCopyWith<_Round> get copyWith =>
      __$RoundCopyWithImpl<_Round>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_RoundToJson(this);
  }
}

abstract class _Round implements Round {
  const factory _Round(
      {required String asking,
      String? to,
      required List<String> clues,
      required String place,
      Map<String, bool?> answers,
      String? roundAnswer,
      bool? accusing}) = _$_Round;

  factory _Round.fromJson(Map<String, dynamic> json) = _$_Round.fromJson;

  @override
  String get asking;
  @override
  String? get to;
  @override
  List<String> get clues;
  @override
  String get place;
  @override
  Map<String, bool?> get answers;
  @override
  String? get roundAnswer;
  @override
  bool? get accusing;
  @override
  @JsonKey(ignore: true)
  _$RoundCopyWith<_Round> get copyWith => throw _privateConstructorUsedError;
}
