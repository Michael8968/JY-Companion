import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:jy_companion/core/error/either.dart';
import 'package:jy_companion/core/error/failures.dart';
import 'package:jy_companion/features/admin/domain/entities/crisis_alert_summary.dart';
import 'package:jy_companion/features/admin/domain/entities/platform_stats.dart';
import 'package:jy_companion/features/admin/domain/entities/user_summary.dart';
import 'package:jy_companion/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:jy_companion/features/admin/presentation/bloc/admin_event.dart';
import 'package:jy_companion/features/admin/presentation/bloc/admin_state.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late MockGetPlatformStatsUseCase mockGetStats;
  late MockGetAdminUsersUseCase mockGetUsers;
  late MockUpdateUserStatusUseCase mockUpdateUserStatus;
  late MockGetAlertsUseCase mockGetAlerts;
  late MockResolveAlertUseCase mockResolveAlert;

  final testStats = const PlatformStats(
    totalUsers: 10,
    activeUsersToday: 3,
    totalConversations: 50,
    totalMessages: 200,
    activeCrisisAlerts: 0,
  );

  final testUser = UserSummary(
    id: 'u1',
    username: 'admin',
    role: 'admin',
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
  );

  final testAlert = CrisisAlertSummary(
    id: 'a1',
    userId: 'u1',
    alertLevel: 'medium',
    status: 'active',
    triggerType: 'keyword',
    triggerContent: 'test',
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockGetStats = MockGetPlatformStatsUseCase();
    mockGetUsers = MockGetAdminUsersUseCase();
    mockUpdateUserStatus = MockUpdateUserStatusUseCase();
    mockGetAlerts = MockGetAlertsUseCase();
    mockResolveAlert = MockResolveAlertUseCase();
  });

  AdminBloc buildBloc() => AdminBloc(
        mockGetStats,
        mockGetUsers,
        mockUpdateUserStatus,
        mockGetAlerts,
        mockResolveAlert,
      );

  group('AdminBloc', () {
    test('initial state is empty', () {
      expect(buildBloc().state, const AdminState());
    });

    group('AdminLoadEvent', () {
      blocTest<AdminBloc, AdminState>(
        'emits [loading, then state with stats] when getStats succeeds',
        setUp: () {
          when(() => mockGetStats()).thenAnswer((_) async => Right(testStats));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AdminLoadEvent()),
        expect: () => [
          const AdminState(isLoading: true, errorMessage: null),
          AdminState(isLoading: false, stats: testStats),
        ],
      );

      blocTest<AdminBloc, AdminState>(
        'emits [loading, then state with errorMessage] when getStats fails',
        setUp: () {
          when(() => mockGetStats()).thenAnswer(
            (_) async => const Left(ServerFailure('网络错误')),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AdminLoadEvent()),
        expect: () => [
          const AdminState(isLoading: true, errorMessage: null),
          const AdminState(isLoading: false, errorMessage: '网络错误'),
        ],
      );
    });

    group('AdminLoadUsersEvent', () {
      blocTest<AdminBloc, AdminState>(
        'emits state with users and total when getUsers succeeds',
        setUp: () {
          when(() => mockGetUsers(page: 1, size: 20, role: null))
              .thenAnswer((_) async => Right((users: [testUser], total: 1)));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AdminLoadUsersEvent()),
        expect: () => [
          AdminState(users: [testUser], usersTotal: 1),
        ],
      );
    });

    group('AdminLoadAlertsEvent', () {
      blocTest<AdminBloc, AdminState>(
        'emits state with alerts and total when getAlerts succeeds',
        setUp: () {
          when(() => mockGetAlerts(page: 1, size: 20, status: null))
              .thenAnswer((_) async => Right((alerts: [testAlert], total: 1)));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AdminLoadAlertsEvent()),
        expect: () => [
          AdminState(alerts: [testAlert], alertsTotal: 1),
        ],
      );
    });

    group('AdminUpdateUserStatusEvent', () {
      blocTest<AdminBloc, AdminState>(
        'updates user in list when updateUserStatus succeeds',
        seed: () => AdminState(users: [testUser], usersTotal: 1),
        setUp: () {
          when(() => mockUpdateUserStatus('u1', false))
              .thenAnswer((_) async => const Right(null));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AdminUpdateUserStatusEvent(
              userId: 'u1',
              isActive: false,
            )),
        expect: () => [
          AdminState(
            users: [
              UserSummary(
                id: testUser.id,
                username: testUser.username,
                role: testUser.role,
                isActive: false,
                createdAt: testUser.createdAt,
              ),
            ],
            usersTotal: 1,
          ),
        ],
      );
    });

    group('AdminResolveAlertEvent', () {
      blocTest<AdminBloc, AdminState>(
        'removes alert from list when resolveAlert succeeds',
        seed: () => AdminState(alerts: [testAlert], alertsTotal: 1),
        setUp: () {
          when(() => mockResolveAlert('a1', notes: null))
              .thenAnswer((_) async => const Right(null));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AdminResolveAlertEvent(alertId: 'a1')),
        expect: () => [
          const AdminState(alerts: [], alertsTotal: 0),
        ],
      );
    });
  });
}
