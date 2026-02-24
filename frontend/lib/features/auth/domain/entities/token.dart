import 'package:freezed_annotation/freezed_annotation.dart';

part 'token.freezed.dart';

@freezed
class Token with _$Token {
  const factory Token({
    required String accessToken,
    required String refreshToken,
    @Default('bearer') String tokenType,
  }) = _Token;
}
