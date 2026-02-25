import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/user_summary.dart';
import '../../domain/usecases/get_alerts_usecase.dart';
import '../../domain/usecases/get_platform_stats_usecase.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/resolve_alert_usecase.dart';
import '../../domain/usecases/update_user_status_usecase.dart';
import 'admin_event.dart';
import 'admin_state.dart';

@injectable
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc(
    this._getStats,
    this._getUsers,
    this._updateUserStatus,
    this._getAlerts,
    this._resolveAlert,
  ) : super(const AdminState()) {
    on<AdminLoadEvent>(_onLoad);
    on<AdminLoadUsersEvent>(_onLoadUsers);
    on<AdminUpdateUserStatusEvent>(_onUpdateUserStatus);
    on<AdminLoadAlertsEvent>(_onLoadAlerts);
    on<AdminResolveAlertEvent>(_onResolveAlert);
  }

  final GetPlatformStatsUseCase _getStats;
  final GetAdminUsersUseCase _getUsers;
  final UpdateUserStatusUseCase _updateUserStatus;
  final GetAlertsUseCase _getAlerts;
  final ResolveAlertUseCase _resolveAlert;

  Future<void> _onLoad(
    AdminLoadEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _getStats();
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (stats) => emit(state.copyWith(isLoading: false, stats: stats)),
    );
  }

  Future<void> _onLoadUsers(
    AdminLoadUsersEvent event,
    Emitter<AdminState> emit,
  ) async {
    final result = await _getUsers(page: event.page, role: event.role);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (data) => emit(state.copyWith(
        users: data.users,
        usersTotal: data.total,
      )),
    );
  }

  Future<void> _onUpdateUserStatus(
    AdminUpdateUserStatusEvent event,
    Emitter<AdminState> emit,
  ) async {
    final result = await _updateUserStatus(event.userId, event.isActive);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(
        users: state.users
            .map((u) => u.id == event.userId
                ? UserSummary(
                    id: u.id,
                    username: u.username,
                    role: u.role,
                    isActive: event.isActive,
                    createdAt: u.createdAt,
                  )
                : u)
            .toList(),
      )),
    );
  }

  Future<void> _onLoadAlerts(
    AdminLoadAlertsEvent event,
    Emitter<AdminState> emit,
  ) async {
    final result = await _getAlerts(page: event.page, status: event.status);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (data) => emit(state.copyWith(
        alerts: data.alerts,
        alertsTotal: data.total,
      )),
    );
  }

  Future<void> _onResolveAlert(
    AdminResolveAlertEvent event,
    Emitter<AdminState> emit,
  ) async {
    final result = await _resolveAlert(event.alertId, notes: event.notes);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(
        alerts: state.alerts
            .where((a) => a.id != event.alertId)
            .toList(),
        alertsTotal: state.alertsTotal > 0 ? state.alertsTotal - 1 : 0,
      )),
    );
  }
}
