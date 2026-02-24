import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:jy_companion/core/error/either.dart';
import 'package:jy_companion/core/error/failures.dart';
import 'package:jy_companion/features/auth/domain/entities/user.dart';
import 'package:jy_companion/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:jy_companion/features/auth/presentation/bloc/auth_event.dart';
import 'package:jy_companion/features/auth/presentation/bloc/auth_state.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  const testUser = User(
    id: '550e8400-e29b-41d4-a716-446655440000',
    username: 'student01',
    displayName: '张三',
    role: 'student',
    createdAt: null,
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
  });

  AuthBloc buildBloc() => AuthBloc(
        mockLoginUseCase,
        mockRegisterUseCase,
        mockLogoutUseCase,
        mockGetCurrentUserUseCase,
      );

  group('AuthBloc', () {
    test('initial state is AuthState.initial', () {
      expect(buildBloc().state, const AuthState.initial());
    });

    group('AppStarted', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] when getCurrentUser succeeds',
        setUp: () {
          when(() => mockGetCurrentUserUseCase())
              .thenAnswer((_) async => const Right(testUser));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AuthEvent.appStarted()),
        expect: () => [
          const AuthState.loading(),
          const AuthState.authenticated(testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, unauthenticated] when getCurrentUser fails',
        setUp: () {
          when(() => mockGetCurrentUserUseCase())
              .thenAnswer((_) async => const Left(UnauthorizedFailure()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AuthEvent.appStarted()),
        expect: () => [
          const AuthState.loading(),
          const AuthState.unauthenticated(),
        ],
      );
    });

    group('LoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] when login succeeds',
        setUp: () {
          when(() => mockLoginUseCase(any(), any()))
              .thenAnswer((_) async => const Right(testUser));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const AuthEvent.loginRequested(
            username: 'student01',
            password: 'pass123',
          ),
        ),
        expect: () => [
          const AuthState.loading(),
          const AuthState.authenticated(testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, error] when login fails',
        setUp: () {
          when(() => mockLoginUseCase(any(), any())).thenAnswer(
            (_) async =>
                const Left(ServerFailure('用户名或密码错误', statusCode: 401)),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const AuthEvent.loginRequested(
            username: 'student01',
            password: 'wrong',
          ),
        ),
        expect: () => [
          const AuthState.loading(),
          const AuthState.error('用户名或密码错误'),
        ],
      );
    });

    group('LogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] when logout is requested',
        setUp: () {
          when(() => mockLogoutUseCase())
              .thenAnswer((_) async => const Right(null));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AuthEvent.logoutRequested()),
        expect: () => [
          const AuthState.unauthenticated(),
        ],
      );
    });
  });
}
