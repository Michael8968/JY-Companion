// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'persona_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PersonaModel {
  String get id;
  String get name;
  String get displayName;
  String? get avatarUrl;
  String? get description;
  Map<String, dynamic>? get personalityTraits;
  String? get speakingStyle;
  String? get tone;
  String? get catchphrase;
  String? get vocabularyLevel;
  String? get emojiUsage;
  String? get humorLevel;
  String? get formality;
  String? get empathyLevel;
  Map<String, dynamic>? get knowledgeDomains;
  Map<String, dynamic>? get preferredAgentTypes;
  String? get voiceStyle;
  String? get voiceSpeed;
  String? get animationSet;
  String? get responseLength;
  String? get encouragementStyle;
  String? get teachingApproach;
  bool get isPreset;
  bool get isActive;
  int get version;
  DateTime get createdAt;

  /// Create a copy of PersonaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PersonaModelCopyWith<PersonaModel> get copyWith =>
      _$PersonaModelCopyWithImpl<PersonaModel>(
          this as PersonaModel, _$identity);

  /// Serializes this PersonaModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PersonaModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other.personalityTraits, personalityTraits) &&
            (identical(other.speakingStyle, speakingStyle) ||
                other.speakingStyle == speakingStyle) &&
            (identical(other.tone, tone) || other.tone == tone) &&
            (identical(other.catchphrase, catchphrase) ||
                other.catchphrase == catchphrase) &&
            (identical(other.vocabularyLevel, vocabularyLevel) ||
                other.vocabularyLevel == vocabularyLevel) &&
            (identical(other.emojiUsage, emojiUsage) ||
                other.emojiUsage == emojiUsage) &&
            (identical(other.humorLevel, humorLevel) ||
                other.humorLevel == humorLevel) &&
            (identical(other.formality, formality) ||
                other.formality == formality) &&
            (identical(other.empathyLevel, empathyLevel) ||
                other.empathyLevel == empathyLevel) &&
            const DeepCollectionEquality()
                .equals(other.knowledgeDomains, knowledgeDomains) &&
            const DeepCollectionEquality()
                .equals(other.preferredAgentTypes, preferredAgentTypes) &&
            (identical(other.voiceStyle, voiceStyle) ||
                other.voiceStyle == voiceStyle) &&
            (identical(other.voiceSpeed, voiceSpeed) ||
                other.voiceSpeed == voiceSpeed) &&
            (identical(other.animationSet, animationSet) ||
                other.animationSet == animationSet) &&
            (identical(other.responseLength, responseLength) ||
                other.responseLength == responseLength) &&
            (identical(other.encouragementStyle, encouragementStyle) ||
                other.encouragementStyle == encouragementStyle) &&
            (identical(other.teachingApproach, teachingApproach) ||
                other.teachingApproach == teachingApproach) &&
            (identical(other.isPreset, isPreset) ||
                other.isPreset == isPreset) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        displayName,
        avatarUrl,
        description,
        const DeepCollectionEquality().hash(personalityTraits),
        speakingStyle,
        tone,
        catchphrase,
        vocabularyLevel,
        emojiUsage,
        humorLevel,
        formality,
        empathyLevel,
        const DeepCollectionEquality().hash(knowledgeDomains),
        const DeepCollectionEquality().hash(preferredAgentTypes),
        voiceStyle,
        voiceSpeed,
        animationSet,
        responseLength,
        encouragementStyle,
        teachingApproach,
        isPreset,
        isActive,
        version,
        createdAt
      ]);

  @override
  String toString() {
    return 'PersonaModel(id: $id, name: $name, displayName: $displayName, avatarUrl: $avatarUrl, description: $description, personalityTraits: $personalityTraits, speakingStyle: $speakingStyle, tone: $tone, catchphrase: $catchphrase, vocabularyLevel: $vocabularyLevel, emojiUsage: $emojiUsage, humorLevel: $humorLevel, formality: $formality, empathyLevel: $empathyLevel, knowledgeDomains: $knowledgeDomains, preferredAgentTypes: $preferredAgentTypes, voiceStyle: $voiceStyle, voiceSpeed: $voiceSpeed, animationSet: $animationSet, responseLength: $responseLength, encouragementStyle: $encouragementStyle, teachingApproach: $teachingApproach, isPreset: $isPreset, isActive: $isActive, version: $version, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $PersonaModelCopyWith<$Res> {
  factory $PersonaModelCopyWith(
          PersonaModel value, $Res Function(PersonaModel) _then) =
      _$PersonaModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String displayName,
      String? avatarUrl,
      String? description,
      Map<String, dynamic>? personalityTraits,
      String? speakingStyle,
      String? tone,
      String? catchphrase,
      String? vocabularyLevel,
      String? emojiUsage,
      String? humorLevel,
      String? formality,
      String? empathyLevel,
      Map<String, dynamic>? knowledgeDomains,
      Map<String, dynamic>? preferredAgentTypes,
      String? voiceStyle,
      String? voiceSpeed,
      String? animationSet,
      String? responseLength,
      String? encouragementStyle,
      String? teachingApproach,
      bool isPreset,
      bool isActive,
      int version,
      DateTime createdAt});
}

/// @nodoc
class _$PersonaModelCopyWithImpl<$Res> implements $PersonaModelCopyWith<$Res> {
  _$PersonaModelCopyWithImpl(this._self, this._then);

  final PersonaModel _self;
  final $Res Function(PersonaModel) _then;

  /// Create a copy of PersonaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? displayName = null,
    Object? avatarUrl = freezed,
    Object? description = freezed,
    Object? personalityTraits = freezed,
    Object? speakingStyle = freezed,
    Object? tone = freezed,
    Object? catchphrase = freezed,
    Object? vocabularyLevel = freezed,
    Object? emojiUsage = freezed,
    Object? humorLevel = freezed,
    Object? formality = freezed,
    Object? empathyLevel = freezed,
    Object? knowledgeDomains = freezed,
    Object? preferredAgentTypes = freezed,
    Object? voiceStyle = freezed,
    Object? voiceSpeed = freezed,
    Object? animationSet = freezed,
    Object? responseLength = freezed,
    Object? encouragementStyle = freezed,
    Object? teachingApproach = freezed,
    Object? isPreset = null,
    Object? isActive = null,
    Object? version = null,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _self.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      personalityTraits: freezed == personalityTraits
          ? _self.personalityTraits
          : personalityTraits // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      speakingStyle: freezed == speakingStyle
          ? _self.speakingStyle
          : speakingStyle // ignore: cast_nullable_to_non_nullable
              as String?,
      tone: freezed == tone
          ? _self.tone
          : tone // ignore: cast_nullable_to_non_nullable
              as String?,
      catchphrase: freezed == catchphrase
          ? _self.catchphrase
          : catchphrase // ignore: cast_nullable_to_non_nullable
              as String?,
      vocabularyLevel: freezed == vocabularyLevel
          ? _self.vocabularyLevel
          : vocabularyLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      emojiUsage: freezed == emojiUsage
          ? _self.emojiUsage
          : emojiUsage // ignore: cast_nullable_to_non_nullable
              as String?,
      humorLevel: freezed == humorLevel
          ? _self.humorLevel
          : humorLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      formality: freezed == formality
          ? _self.formality
          : formality // ignore: cast_nullable_to_non_nullable
              as String?,
      empathyLevel: freezed == empathyLevel
          ? _self.empathyLevel
          : empathyLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      knowledgeDomains: freezed == knowledgeDomains
          ? _self.knowledgeDomains
          : knowledgeDomains // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      preferredAgentTypes: freezed == preferredAgentTypes
          ? _self.preferredAgentTypes
          : preferredAgentTypes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      voiceStyle: freezed == voiceStyle
          ? _self.voiceStyle
          : voiceStyle // ignore: cast_nullable_to_non_nullable
              as String?,
      voiceSpeed: freezed == voiceSpeed
          ? _self.voiceSpeed
          : voiceSpeed // ignore: cast_nullable_to_non_nullable
              as String?,
      animationSet: freezed == animationSet
          ? _self.animationSet
          : animationSet // ignore: cast_nullable_to_non_nullable
              as String?,
      responseLength: freezed == responseLength
          ? _self.responseLength
          : responseLength // ignore: cast_nullable_to_non_nullable
              as String?,
      encouragementStyle: freezed == encouragementStyle
          ? _self.encouragementStyle
          : encouragementStyle // ignore: cast_nullable_to_non_nullable
              as String?,
      teachingApproach: freezed == teachingApproach
          ? _self.teachingApproach
          : teachingApproach // ignore: cast_nullable_to_non_nullable
              as String?,
      isPreset: null == isPreset
          ? _self.isPreset
          : isPreset // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      version: null == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [PersonaModel].
extension PersonaModelPatterns on PersonaModel {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PersonaModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PersonaModel() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_PersonaModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonaModel():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PersonaModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonaModel() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String displayName,
            String? avatarUrl,
            String? description,
            Map<String, dynamic>? personalityTraits,
            String? speakingStyle,
            String? tone,
            String? catchphrase,
            String? vocabularyLevel,
            String? emojiUsage,
            String? humorLevel,
            String? formality,
            String? empathyLevel,
            Map<String, dynamic>? knowledgeDomains,
            Map<String, dynamic>? preferredAgentTypes,
            String? voiceStyle,
            String? voiceSpeed,
            String? animationSet,
            String? responseLength,
            String? encouragementStyle,
            String? teachingApproach,
            bool isPreset,
            bool isActive,
            int version,
            DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PersonaModel() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.displayName,
            _that.avatarUrl,
            _that.description,
            _that.personalityTraits,
            _that.speakingStyle,
            _that.tone,
            _that.catchphrase,
            _that.vocabularyLevel,
            _that.emojiUsage,
            _that.humorLevel,
            _that.formality,
            _that.empathyLevel,
            _that.knowledgeDomains,
            _that.preferredAgentTypes,
            _that.voiceStyle,
            _that.voiceSpeed,
            _that.animationSet,
            _that.responseLength,
            _that.encouragementStyle,
            _that.teachingApproach,
            _that.isPreset,
            _that.isActive,
            _that.version,
            _that.createdAt);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String displayName,
            String? avatarUrl,
            String? description,
            Map<String, dynamic>? personalityTraits,
            String? speakingStyle,
            String? tone,
            String? catchphrase,
            String? vocabularyLevel,
            String? emojiUsage,
            String? humorLevel,
            String? formality,
            String? empathyLevel,
            Map<String, dynamic>? knowledgeDomains,
            Map<String, dynamic>? preferredAgentTypes,
            String? voiceStyle,
            String? voiceSpeed,
            String? animationSet,
            String? responseLength,
            String? encouragementStyle,
            String? teachingApproach,
            bool isPreset,
            bool isActive,
            int version,
            DateTime createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonaModel():
        return $default(
            _that.id,
            _that.name,
            _that.displayName,
            _that.avatarUrl,
            _that.description,
            _that.personalityTraits,
            _that.speakingStyle,
            _that.tone,
            _that.catchphrase,
            _that.vocabularyLevel,
            _that.emojiUsage,
            _that.humorLevel,
            _that.formality,
            _that.empathyLevel,
            _that.knowledgeDomains,
            _that.preferredAgentTypes,
            _that.voiceStyle,
            _that.voiceSpeed,
            _that.animationSet,
            _that.responseLength,
            _that.encouragementStyle,
            _that.teachingApproach,
            _that.isPreset,
            _that.isActive,
            _that.version,
            _that.createdAt);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String name,
            String displayName,
            String? avatarUrl,
            String? description,
            Map<String, dynamic>? personalityTraits,
            String? speakingStyle,
            String? tone,
            String? catchphrase,
            String? vocabularyLevel,
            String? emojiUsage,
            String? humorLevel,
            String? formality,
            String? empathyLevel,
            Map<String, dynamic>? knowledgeDomains,
            Map<String, dynamic>? preferredAgentTypes,
            String? voiceStyle,
            String? voiceSpeed,
            String? animationSet,
            String? responseLength,
            String? encouragementStyle,
            String? teachingApproach,
            bool isPreset,
            bool isActive,
            int version,
            DateTime createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonaModel() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.displayName,
            _that.avatarUrl,
            _that.description,
            _that.personalityTraits,
            _that.speakingStyle,
            _that.tone,
            _that.catchphrase,
            _that.vocabularyLevel,
            _that.emojiUsage,
            _that.humorLevel,
            _that.formality,
            _that.empathyLevel,
            _that.knowledgeDomains,
            _that.preferredAgentTypes,
            _that.voiceStyle,
            _that.voiceSpeed,
            _that.animationSet,
            _that.responseLength,
            _that.encouragementStyle,
            _that.teachingApproach,
            _that.isPreset,
            _that.isActive,
            _that.version,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PersonaModel implements PersonaModel {
  const _PersonaModel(
      {required this.id,
      required this.name,
      required this.displayName,
      this.avatarUrl,
      this.description,
      final Map<String, dynamic>? personalityTraits,
      this.speakingStyle,
      this.tone,
      this.catchphrase,
      this.vocabularyLevel,
      this.emojiUsage,
      this.humorLevel,
      this.formality,
      this.empathyLevel,
      final Map<String, dynamic>? knowledgeDomains,
      final Map<String, dynamic>? preferredAgentTypes,
      this.voiceStyle,
      this.voiceSpeed,
      this.animationSet,
      this.responseLength,
      this.encouragementStyle,
      this.teachingApproach,
      required this.isPreset,
      required this.isActive,
      required this.version,
      required this.createdAt})
      : _personalityTraits = personalityTraits,
        _knowledgeDomains = knowledgeDomains,
        _preferredAgentTypes = preferredAgentTypes;
  factory _PersonaModel.fromJson(Map<String, dynamic> json) =>
      _$PersonaModelFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String displayName;
  @override
  final String? avatarUrl;
  @override
  final String? description;
  final Map<String, dynamic>? _personalityTraits;
  @override
  Map<String, dynamic>? get personalityTraits {
    final value = _personalityTraits;
    if (value == null) return null;
    if (_personalityTraits is EqualUnmodifiableMapView)
      return _personalityTraits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? speakingStyle;
  @override
  final String? tone;
  @override
  final String? catchphrase;
  @override
  final String? vocabularyLevel;
  @override
  final String? emojiUsage;
  @override
  final String? humorLevel;
  @override
  final String? formality;
  @override
  final String? empathyLevel;
  final Map<String, dynamic>? _knowledgeDomains;
  @override
  Map<String, dynamic>? get knowledgeDomains {
    final value = _knowledgeDomains;
    if (value == null) return null;
    if (_knowledgeDomains is EqualUnmodifiableMapView) return _knowledgeDomains;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _preferredAgentTypes;
  @override
  Map<String, dynamic>? get preferredAgentTypes {
    final value = _preferredAgentTypes;
    if (value == null) return null;
    if (_preferredAgentTypes is EqualUnmodifiableMapView)
      return _preferredAgentTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? voiceStyle;
  @override
  final String? voiceSpeed;
  @override
  final String? animationSet;
  @override
  final String? responseLength;
  @override
  final String? encouragementStyle;
  @override
  final String? teachingApproach;
  @override
  final bool isPreset;
  @override
  final bool isActive;
  @override
  final int version;
  @override
  final DateTime createdAt;

  /// Create a copy of PersonaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PersonaModelCopyWith<_PersonaModel> get copyWith =>
      __$PersonaModelCopyWithImpl<_PersonaModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PersonaModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PersonaModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._personalityTraits, _personalityTraits) &&
            (identical(other.speakingStyle, speakingStyle) ||
                other.speakingStyle == speakingStyle) &&
            (identical(other.tone, tone) || other.tone == tone) &&
            (identical(other.catchphrase, catchphrase) ||
                other.catchphrase == catchphrase) &&
            (identical(other.vocabularyLevel, vocabularyLevel) ||
                other.vocabularyLevel == vocabularyLevel) &&
            (identical(other.emojiUsage, emojiUsage) ||
                other.emojiUsage == emojiUsage) &&
            (identical(other.humorLevel, humorLevel) ||
                other.humorLevel == humorLevel) &&
            (identical(other.formality, formality) ||
                other.formality == formality) &&
            (identical(other.empathyLevel, empathyLevel) ||
                other.empathyLevel == empathyLevel) &&
            const DeepCollectionEquality()
                .equals(other._knowledgeDomains, _knowledgeDomains) &&
            const DeepCollectionEquality()
                .equals(other._preferredAgentTypes, _preferredAgentTypes) &&
            (identical(other.voiceStyle, voiceStyle) ||
                other.voiceStyle == voiceStyle) &&
            (identical(other.voiceSpeed, voiceSpeed) ||
                other.voiceSpeed == voiceSpeed) &&
            (identical(other.animationSet, animationSet) ||
                other.animationSet == animationSet) &&
            (identical(other.responseLength, responseLength) ||
                other.responseLength == responseLength) &&
            (identical(other.encouragementStyle, encouragementStyle) ||
                other.encouragementStyle == encouragementStyle) &&
            (identical(other.teachingApproach, teachingApproach) ||
                other.teachingApproach == teachingApproach) &&
            (identical(other.isPreset, isPreset) ||
                other.isPreset == isPreset) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        displayName,
        avatarUrl,
        description,
        const DeepCollectionEquality().hash(_personalityTraits),
        speakingStyle,
        tone,
        catchphrase,
        vocabularyLevel,
        emojiUsage,
        humorLevel,
        formality,
        empathyLevel,
        const DeepCollectionEquality().hash(_knowledgeDomains),
        const DeepCollectionEquality().hash(_preferredAgentTypes),
        voiceStyle,
        voiceSpeed,
        animationSet,
        responseLength,
        encouragementStyle,
        teachingApproach,
        isPreset,
        isActive,
        version,
        createdAt
      ]);

  @override
  String toString() {
    return 'PersonaModel(id: $id, name: $name, displayName: $displayName, avatarUrl: $avatarUrl, description: $description, personalityTraits: $personalityTraits, speakingStyle: $speakingStyle, tone: $tone, catchphrase: $catchphrase, vocabularyLevel: $vocabularyLevel, emojiUsage: $emojiUsage, humorLevel: $humorLevel, formality: $formality, empathyLevel: $empathyLevel, knowledgeDomains: $knowledgeDomains, preferredAgentTypes: $preferredAgentTypes, voiceStyle: $voiceStyle, voiceSpeed: $voiceSpeed, animationSet: $animationSet, responseLength: $responseLength, encouragementStyle: $encouragementStyle, teachingApproach: $teachingApproach, isPreset: $isPreset, isActive: $isActive, version: $version, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$PersonaModelCopyWith<$Res>
    implements $PersonaModelCopyWith<$Res> {
  factory _$PersonaModelCopyWith(
          _PersonaModel value, $Res Function(_PersonaModel) _then) =
      __$PersonaModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String displayName,
      String? avatarUrl,
      String? description,
      Map<String, dynamic>? personalityTraits,
      String? speakingStyle,
      String? tone,
      String? catchphrase,
      String? vocabularyLevel,
      String? emojiUsage,
      String? humorLevel,
      String? formality,
      String? empathyLevel,
      Map<String, dynamic>? knowledgeDomains,
      Map<String, dynamic>? preferredAgentTypes,
      String? voiceStyle,
      String? voiceSpeed,
      String? animationSet,
      String? responseLength,
      String? encouragementStyle,
      String? teachingApproach,
      bool isPreset,
      bool isActive,
      int version,
      DateTime createdAt});
}

/// @nodoc
class __$PersonaModelCopyWithImpl<$Res>
    implements _$PersonaModelCopyWith<$Res> {
  __$PersonaModelCopyWithImpl(this._self, this._then);

  final _PersonaModel _self;
  final $Res Function(_PersonaModel) _then;

  /// Create a copy of PersonaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? displayName = null,
    Object? avatarUrl = freezed,
    Object? description = freezed,
    Object? personalityTraits = freezed,
    Object? speakingStyle = freezed,
    Object? tone = freezed,
    Object? catchphrase = freezed,
    Object? vocabularyLevel = freezed,
    Object? emojiUsage = freezed,
    Object? humorLevel = freezed,
    Object? formality = freezed,
    Object? empathyLevel = freezed,
    Object? knowledgeDomains = freezed,
    Object? preferredAgentTypes = freezed,
    Object? voiceStyle = freezed,
    Object? voiceSpeed = freezed,
    Object? animationSet = freezed,
    Object? responseLength = freezed,
    Object? encouragementStyle = freezed,
    Object? teachingApproach = freezed,
    Object? isPreset = null,
    Object? isActive = null,
    Object? version = null,
    Object? createdAt = null,
  }) {
    return _then(_PersonaModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _self.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      personalityTraits: freezed == personalityTraits
          ? _self._personalityTraits
          : personalityTraits // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      speakingStyle: freezed == speakingStyle
          ? _self.speakingStyle
          : speakingStyle // ignore: cast_nullable_to_non_nullable
              as String?,
      tone: freezed == tone
          ? _self.tone
          : tone // ignore: cast_nullable_to_non_nullable
              as String?,
      catchphrase: freezed == catchphrase
          ? _self.catchphrase
          : catchphrase // ignore: cast_nullable_to_non_nullable
              as String?,
      vocabularyLevel: freezed == vocabularyLevel
          ? _self.vocabularyLevel
          : vocabularyLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      emojiUsage: freezed == emojiUsage
          ? _self.emojiUsage
          : emojiUsage // ignore: cast_nullable_to_non_nullable
              as String?,
      humorLevel: freezed == humorLevel
          ? _self.humorLevel
          : humorLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      formality: freezed == formality
          ? _self.formality
          : formality // ignore: cast_nullable_to_non_nullable
              as String?,
      empathyLevel: freezed == empathyLevel
          ? _self.empathyLevel
          : empathyLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      knowledgeDomains: freezed == knowledgeDomains
          ? _self._knowledgeDomains
          : knowledgeDomains // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      preferredAgentTypes: freezed == preferredAgentTypes
          ? _self._preferredAgentTypes
          : preferredAgentTypes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      voiceStyle: freezed == voiceStyle
          ? _self.voiceStyle
          : voiceStyle // ignore: cast_nullable_to_non_nullable
              as String?,
      voiceSpeed: freezed == voiceSpeed
          ? _self.voiceSpeed
          : voiceSpeed // ignore: cast_nullable_to_non_nullable
              as String?,
      animationSet: freezed == animationSet
          ? _self.animationSet
          : animationSet // ignore: cast_nullable_to_non_nullable
              as String?,
      responseLength: freezed == responseLength
          ? _self.responseLength
          : responseLength // ignore: cast_nullable_to_non_nullable
              as String?,
      encouragementStyle: freezed == encouragementStyle
          ? _self.encouragementStyle
          : encouragementStyle // ignore: cast_nullable_to_non_nullable
              as String?,
      teachingApproach: freezed == teachingApproach
          ? _self.teachingApproach
          : teachingApproach // ignore: cast_nullable_to_non_nullable
              as String?,
      isPreset: null == isPreset
          ? _self.isPreset
          : isPreset // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      version: null == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
