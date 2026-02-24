import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthBloc(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
  ) : super(const AuthState.initial()) {
    on<AuthEvent>(_onEvent);
  }

  Future<void> _onEvent(AuthEvent event, Emitter<AuthState> emit) async {
    await event.when(
      appStarted: () => _onAppStarted(emit),
      loginRequested: (username, password) =>
          _onLoginRequested(username, password, emit),
      registerRequested: (username, password, displayName, role, email, phone,
              grade, className, studentId) =>
          _onRegisterRequested(
        username: username,
        password: password,
        displayName: displayName,
        role: role,
        email: email,
        phone: phone,
        grade: grade,
        className: className,
        studentId: studentId,
        emit: emit,
      ),
      logoutRequested: () => _onLogoutRequested(emit),
    );
  }

  Future<void> _onAppStarted(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => emit(const AuthState.unauthenticated()),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onLoginRequested(
    String username,
    String password,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _loginUseCase(username, password);
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onRegisterRequested({
    required String username,
    required String password,
    required String displayName,
    required String role,
    String? email,
    String? phone,
    String? grade,
    String? className,
    String? studentId,
    required Emitter<AuthState> emit,
  }) async {
    emit(const AuthState.loading());
    final result = await _registerUseCase(
      username: username,
      password: password,
      displayName: displayName,
      role: role,
      email: email,
      phone: phone,
      grade: grade,
      className: className,
      studentId: studentId,
    );
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) {
        // After registration, user needs to login
        emit(const AuthState.unauthenticated());
      },
    );
  }

  Future<void> _onLogoutRequested(Emitter<AuthState> emit) async {
    await _logoutUseCase();
    emit(const AuthState.unauthenticated());
  }
}
