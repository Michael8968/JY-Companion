import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String username,
    required String displayName,
    required String role,
    String? email,
    String? avatarUrl,
    String? grade,
    String? className,
    String? studentId,
    DateTime? lastLoginAt,
    required DateTime createdAt,
  }) = _User;
}
