import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.appStarted() = _AppStarted;

  const factory AuthEvent.loginRequested({
    required String username,
    required String password,
  }) = _LoginRequested;

  const factory AuthEvent.registerRequested({
    required String username,
    required String password,
    required String displayName,
    @Default('student') String role,
    String? email,
    String? phone,
    String? grade,
    String? className,
    String? studentId,
  }) = _RegisterRequested;

  const factory AuthEvent.logoutRequested() = _LogoutRequested;
}
