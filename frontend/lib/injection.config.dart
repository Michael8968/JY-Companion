// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'core/network/api_client.dart' as _i871;
import 'core/network/api_interceptors.dart' as _i9;
import 'core/network/network_info.dart' as _i75;
import 'core/network/token_manager.dart' as _i1052;
import 'core/router/app_router.dart' as _i110;
import 'features/academic/data/datasources/academic_remote_data_source.dart'
    as _i305;
import 'features/academic/data/repositories/academic_repository_impl.dart'
    as _i119;
import 'features/academic/domain/repositories/academic_repository.dart'
    as _i935;
import 'features/academic/domain/usecases/get_error_book_usecase.dart' as _i314;
import 'features/academic/domain/usecases/review_error_usecase.dart' as _i266;
import 'features/academic/presentation/bloc/error_book_bloc.dart' as _i567;
import 'features/admin/data/datasources/admin_remote_data_source.dart' as _i753;
import 'features/admin/data/repositories/admin_repository_impl.dart' as _i484;
import 'features/admin/domain/repositories/admin_repository.dart' as _i609;
import 'features/admin/domain/usecases/get_alerts_usecase.dart' as _i402;
import 'features/admin/domain/usecases/get_platform_stats_usecase.dart'
    as _i972;
import 'features/admin/domain/usecases/get_users_usecase.dart' as _i525;
import 'features/admin/domain/usecases/resolve_alert_usecase.dart' as _i277;
import 'features/admin/domain/usecases/update_user_status_usecase.dart'
    as _i414;
import 'features/admin/presentation/bloc/admin_bloc.dart' as _i748;
import 'features/auth/data/datasources/auth_remote_data_source.dart' as _i767;
import 'features/auth/data/repositories/auth_repository_impl.dart' as _i111;
import 'features/auth/domain/repositories/auth_repository.dart' as _i1015;
import 'features/auth/domain/usecases/get_current_user_usecase.dart' as _i630;
import 'features/auth/domain/usecases/login_usecase.dart' as _i206;
import 'features/auth/domain/usecases/logout_usecase.dart' as _i824;
import 'features/auth/domain/usecases/register_usecase.dart' as _i693;
import 'features/auth/presentation/bloc/auth_bloc.dart' as _i363;
import 'features/career/data/datasources/career_remote_data_source.dart'
    as _i600;
import 'features/career/data/repositories/career_repository_impl.dart' as _i558;
import 'features/career/domain/repositories/career_repository.dart' as _i965;
import 'features/career/domain/usecases/create_goal_usecase.dart' as _i784;
import 'features/career/domain/usecases/generate_progress_report_usecase.dart'
    as _i145;
import 'features/career/domain/usecases/get_goals_usecase.dart' as _i620;
import 'features/career/domain/usecases/get_progress_reports_usecase.dart'
    as _i357;
import 'features/career/domain/usecases/update_goal_usecase.dart' as _i45;
import 'features/career/presentation/bloc/career_bloc.dart' as _i269;
import 'features/chat/data/datasources/chat_remote_data_source.dart' as _i1000;
import 'features/chat/data/datasources/chat_ws_data_source.dart' as _i548;
import 'features/chat/data/repositories/chat_repository_impl.dart' as _i382;
import 'features/chat/domain/repositories/chat_repository.dart' as _i453;
import 'features/chat/domain/usecases/create_conversation_usecase.dart'
    as _i707;
import 'features/chat/domain/usecases/delete_conversation_usecase.dart'
    as _i689;
import 'features/chat/domain/usecases/get_messages_usecase.dart' as _i350;
import 'features/chat/domain/usecases/list_conversations_usecase.dart' as _i139;
import 'features/chat/presentation/bloc/chat/chat_bloc.dart' as _i561;
import 'features/chat/presentation/bloc/conversation_list/conversation_list_bloc.dart'
    as _i384;
import 'features/classroom/data/datasources/classroom_remote_data_source.dart'
    as _i841;
import 'features/classroom/data/repositories/classroom_repository_impl.dart'
    as _i359;
import 'features/classroom/domain/repositories/classroom_repository.dart'
    as _i300;
import 'features/classroom/domain/usecases/create_session_usecase.dart'
    as _i355;
import 'features/classroom/domain/usecases/generate_study_plan_usecase.dart'
    as _i132;
import 'features/classroom/domain/usecases/get_session_doubts_usecase.dart'
    as _i1021;
import 'features/classroom/domain/usecases/get_session_usecase.dart' as _i425;
import 'features/classroom/domain/usecases/transcribe_session_usecase.dart'
    as _i1009;
import 'features/classroom/presentation/bloc/session_detail_bloc.dart'
    as _i1000;
import 'features/creative/data/datasources/creative_remote_data_source.dart'
    as _i80;
import 'features/creative/data/repositories/creative_repository_impl.dart'
    as _i494;
import 'features/creative/domain/repositories/creative_repository.dart'
    as _i613;
import 'features/creative/domain/usecases/evaluate_work_usecase.dart' as _i596;
import 'features/creative/domain/usecases/generate_creative_usecase.dart'
    as _i691;
import 'features/creative/presentation/bloc/creative_bloc.dart' as _i548;
import 'features/emotional/data/datasources/emotional_remote_data_source.dart'
    as _i1000;
import 'features/emotional/data/repositories/emotional_repository_impl.dart'
    as _i971;
import 'features/emotional/domain/repositories/emotional_repository.dart'
    as _i254;
import 'features/emotional/domain/usecases/create_gratitude_entry_usecase.dart'
    as _i476;
import 'features/emotional/domain/usecases/get_emotion_history_usecase.dart'
    as _i245;
import 'features/emotional/domain/usecases/get_gratitude_entries_usecase.dart'
    as _i334;
import 'features/emotional/presentation/bloc/emotional_bloc.dart' as _i771;
import 'features/health/data/datasources/health_remote_data_source.dart'
    as _i192;
import 'features/health/data/repositories/health_repository_impl.dart' as _i687;
import 'features/health/domain/repositories/health_repository.dart' as _i377;
import 'features/health/domain/usecases/complete_exercise_usecase.dart'
    as _i708;
import 'features/health/domain/usecases/get_exercise_plan_usecase.dart'
    as _i894;
import 'features/health/domain/usecases/get_reminder_config_usecase.dart'
    as _i832;
import 'features/health/domain/usecases/get_screen_time_history_usecase.dart'
    as _i631;
import 'features/health/domain/usecases/update_reminder_config_usecase.dart'
    as _i529;
import 'features/health/presentation/bloc/health_bloc.dart' as _i483;
import 'features/persona/data/datasources/persona_remote_data_source.dart'
    as _i498;
import 'features/persona/data/repositories/persona_repository_impl.dart'
    as _i348;
import 'features/persona/domain/repositories/persona_repository.dart' as _i406;
import 'features/persona/domain/usecases/bind_persona_usecase.dart' as _i165;
import 'features/persona/domain/usecases/list_bindings_usecase.dart' as _i592;
import 'features/persona/domain/usecases/list_personas_usecase.dart' as _i244;
import 'features/persona/presentation/bloc/persona_bloc.dart' as _i792;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final connectivityModule = _$ConnectivityModule();
    final networkModule = _$NetworkModule();
    gh.singleton<_i895.Connectivity>(() => connectivityModule.connectivity);
    gh.singleton<_i1052.TokenManager>(() => _i1052.TokenManager());
    gh.singleton<_i110.AppRouterConfig>(
      () => _i110.AppRouterConfig(gh<_i1052.TokenManager>()),
    );
    gh.factory<_i9.AuthInterceptor>(
      () => _i9.AuthInterceptor(gh<_i1052.TokenManager>()),
    );
    gh.factory<_i548.ChatWsDataSource>(
      () => _i548.ChatWsDataSource(gh<_i1052.TokenManager>()),
    );
    gh.factory<_i75.NetworkInfo>(
      () => _i75.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.singleton<_i361.Dio>(() => networkModule.dio(gh<_i1052.TokenManager>()));
    gh.factory<_i305.AcademicRemoteDataSource>(
      () => _i305.AcademicRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i753.AdminRemoteDataSource>(
      () => _i753.AdminRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i767.AuthRemoteDataSource>(
      () => _i767.AuthRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i600.CareerRemoteDataSource>(
      () => _i600.CareerRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i1000.ChatRemoteDataSource>(
      () => _i1000.ChatRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i841.ClassroomRemoteDataSource>(
      () => _i841.ClassroomRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i80.CreativeRemoteDataSource>(
      () => _i80.CreativeRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i1000.EmotionalRemoteDataSource>(
      () => _i1000.EmotionalRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i192.HealthRemoteDataSource>(
      () => _i192.HealthRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i498.PersonaRemoteDataSource>(
      () => _i498.PersonaRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i300.ClassroomRepository>(
      () =>
          _i359.ClassroomRepositoryImpl(gh<_i841.ClassroomRemoteDataSource>()),
    );
    gh.factory<_i613.CreativeRepository>(
      () => _i494.CreativeRepositoryImpl(gh<_i80.CreativeRemoteDataSource>()),
    );
    gh.factory<_i254.EmotionalRepository>(
      () =>
          _i971.EmotionalRepositoryImpl(gh<_i1000.EmotionalRemoteDataSource>()),
    );
    gh.factory<_i377.HealthRepository>(
      () => _i687.HealthRepositoryImpl(gh<_i192.HealthRemoteDataSource>()),
    );
    gh.factory<_i406.PersonaRepository>(
      () => _i348.PersonaRepositoryImpl(gh<_i498.PersonaRemoteDataSource>()),
    );
    gh.factory<_i935.AcademicRepository>(
      () => _i119.AcademicRepositoryImpl(gh<_i305.AcademicRemoteDataSource>()),
    );
    gh.factory<_i708.CompleteExerciseUseCase>(
      () => _i708.CompleteExerciseUseCase(gh<_i377.HealthRepository>()),
    );
    gh.factory<_i894.GetExercisePlanUseCase>(
      () => _i894.GetExercisePlanUseCase(gh<_i377.HealthRepository>()),
    );
    gh.factory<_i832.GetReminderConfigUseCase>(
      () => _i832.GetReminderConfigUseCase(gh<_i377.HealthRepository>()),
    );
    gh.factory<_i631.GetScreenTimeHistoryUseCase>(
      () => _i631.GetScreenTimeHistoryUseCase(gh<_i377.HealthRepository>()),
    );
    gh.factory<_i529.UpdateReminderConfigUseCase>(
      () => _i529.UpdateReminderConfigUseCase(gh<_i377.HealthRepository>()),
    );
    gh.factory<_i965.CareerRepository>(
      () => _i558.CareerRepositoryImpl(gh<_i600.CareerRemoteDataSource>()),
    );
    gh.factory<_i609.AdminRepository>(
      () => _i484.AdminRepositoryImpl(gh<_i753.AdminRemoteDataSource>()),
    );
    gh.factory<_i1015.AuthRepository>(
      () => _i111.AuthRepositoryImpl(
        gh<_i767.AuthRemoteDataSource>(),
        gh<_i1052.TokenManager>(),
      ),
    );
    gh.factory<_i355.CreateSessionUseCase>(
      () => _i355.CreateSessionUseCase(gh<_i300.ClassroomRepository>()),
    );
    gh.factory<_i132.GenerateStudyPlanUseCase>(
      () => _i132.GenerateStudyPlanUseCase(gh<_i300.ClassroomRepository>()),
    );
    gh.factory<_i1021.GetSessionDoubtsUseCase>(
      () => _i1021.GetSessionDoubtsUseCase(gh<_i300.ClassroomRepository>()),
    );
    gh.factory<_i425.GetSessionUseCase>(
      () => _i425.GetSessionUseCase(gh<_i300.ClassroomRepository>()),
    );
    gh.factory<_i1009.TranscribeSessionUseCase>(
      () => _i1009.TranscribeSessionUseCase(gh<_i300.ClassroomRepository>()),
    );
    gh.factory<_i453.ChatRepository>(
      () => _i382.ChatRepositoryImpl(gh<_i1000.ChatRemoteDataSource>()),
    );
    gh.factory<_i596.EvaluateWorkUseCase>(
      () => _i596.EvaluateWorkUseCase(gh<_i613.CreativeRepository>()),
    );
    gh.factory<_i691.GenerateCreativeUseCase>(
      () => _i691.GenerateCreativeUseCase(gh<_i613.CreativeRepository>()),
    );
    gh.factory<_i165.BindPersonaUseCase>(
      () => _i165.BindPersonaUseCase(gh<_i406.PersonaRepository>()),
    );
    gh.factory<_i592.ListBindingsUseCase>(
      () => _i592.ListBindingsUseCase(gh<_i406.PersonaRepository>()),
    );
    gh.factory<_i244.ListPersonasUseCase>(
      () => _i244.ListPersonasUseCase(gh<_i406.PersonaRepository>()),
    );
    gh.factory<_i630.GetCurrentUserUseCase>(
      () => _i630.GetCurrentUserUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.factory<_i206.LoginUseCase>(
      () => _i206.LoginUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.factory<_i824.LogoutUseCase>(
      () => _i824.LogoutUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.factory<_i693.RegisterUseCase>(
      () => _i693.RegisterUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.factory<_i784.CreateGoalUseCase>(
      () => _i784.CreateGoalUseCase(gh<_i965.CareerRepository>()),
    );
    gh.factory<_i145.GenerateProgressReportUseCase>(
      () => _i145.GenerateProgressReportUseCase(gh<_i965.CareerRepository>()),
    );
    gh.factory<_i620.GetGoalsUseCase>(
      () => _i620.GetGoalsUseCase(gh<_i965.CareerRepository>()),
    );
    gh.factory<_i357.GetProgressReportsUseCase>(
      () => _i357.GetProgressReportsUseCase(gh<_i965.CareerRepository>()),
    );
    gh.factory<_i45.UpdateGoalUseCase>(
      () => _i45.UpdateGoalUseCase(gh<_i965.CareerRepository>()),
    );
    gh.factory<_i476.CreateGratitudeEntryUseCase>(
      () => _i476.CreateGratitudeEntryUseCase(gh<_i254.EmotionalRepository>()),
    );
    gh.factory<_i245.GetEmotionHistoryUseCase>(
      () => _i245.GetEmotionHistoryUseCase(gh<_i254.EmotionalRepository>()),
    );
    gh.factory<_i334.GetGratitudeEntriesUseCase>(
      () => _i334.GetGratitudeEntriesUseCase(gh<_i254.EmotionalRepository>()),
    );
    gh.factory<_i1000.SessionDetailBloc>(
      () => _i1000.SessionDetailBloc(
        gh<_i425.GetSessionUseCase>(),
        gh<_i1021.GetSessionDoubtsUseCase>(),
        gh<_i132.GenerateStudyPlanUseCase>(),
      ),
    );
    gh.factory<_i707.CreateConversationUseCase>(
      () => _i707.CreateConversationUseCase(gh<_i453.ChatRepository>()),
    );
    gh.factory<_i689.DeleteConversationUseCase>(
      () => _i689.DeleteConversationUseCase(gh<_i453.ChatRepository>()),
    );
    gh.factory<_i350.GetMessagesUseCase>(
      () => _i350.GetMessagesUseCase(gh<_i453.ChatRepository>()),
    );
    gh.factory<_i139.ListConversationsUseCase>(
      () => _i139.ListConversationsUseCase(gh<_i453.ChatRepository>()),
    );
    gh.factory<_i548.CreativeBloc>(
      () => _i548.CreativeBloc(
        gh<_i691.GenerateCreativeUseCase>(),
        gh<_i596.EvaluateWorkUseCase>(),
      ),
    );
    gh.factory<_i483.HealthBloc>(
      () => _i483.HealthBloc(
        gh<_i631.GetScreenTimeHistoryUseCase>(),
        gh<_i832.GetReminderConfigUseCase>(),
        gh<_i529.UpdateReminderConfigUseCase>(),
        gh<_i894.GetExercisePlanUseCase>(),
        gh<_i708.CompleteExerciseUseCase>(),
      ),
    );
    gh.factory<_i314.GetErrorBookUseCase>(
      () => _i314.GetErrorBookUseCase(gh<_i935.AcademicRepository>()),
    );
    gh.factory<_i266.ReviewErrorUseCase>(
      () => _i266.ReviewErrorUseCase(gh<_i935.AcademicRepository>()),
    );
    gh.factory<_i269.CareerBloc>(
      () => _i269.CareerBloc(
        gh<_i620.GetGoalsUseCase>(),
        gh<_i784.CreateGoalUseCase>(),
        gh<_i45.UpdateGoalUseCase>(),
        gh<_i357.GetProgressReportsUseCase>(),
        gh<_i145.GenerateProgressReportUseCase>(),
      ),
    );
    gh.factory<_i402.GetAlertsUseCase>(
      () => _i402.GetAlertsUseCase(gh<_i609.AdminRepository>()),
    );
    gh.factory<_i972.GetPlatformStatsUseCase>(
      () => _i972.GetPlatformStatsUseCase(gh<_i609.AdminRepository>()),
    );
    gh.factory<_i525.GetAdminUsersUseCase>(
      () => _i525.GetAdminUsersUseCase(gh<_i609.AdminRepository>()),
    );
    gh.factory<_i277.ResolveAlertUseCase>(
      () => _i277.ResolveAlertUseCase(gh<_i609.AdminRepository>()),
    );
    gh.factory<_i414.UpdateUserStatusUseCase>(
      () => _i414.UpdateUserStatusUseCase(gh<_i609.AdminRepository>()),
    );
    gh.factory<_i771.EmotionalBloc>(
      () => _i771.EmotionalBloc(
        gh<_i245.GetEmotionHistoryUseCase>(),
        gh<_i334.GetGratitudeEntriesUseCase>(),
        gh<_i476.CreateGratitudeEntryUseCase>(),
      ),
    );
    gh.factory<_i384.ConversationListBloc>(
      () => _i384.ConversationListBloc(
        gh<_i139.ListConversationsUseCase>(),
        gh<_i707.CreateConversationUseCase>(),
        gh<_i689.DeleteConversationUseCase>(),
      ),
    );
    gh.factory<_i792.PersonaBloc>(
      () => _i792.PersonaBloc(
        gh<_i244.ListPersonasUseCase>(),
        gh<_i165.BindPersonaUseCase>(),
        gh<_i592.ListBindingsUseCase>(),
      ),
    );
    gh.factory<_i363.AuthBloc>(
      () => _i363.AuthBloc(
        gh<_i206.LoginUseCase>(),
        gh<_i693.RegisterUseCase>(),
        gh<_i824.LogoutUseCase>(),
        gh<_i630.GetCurrentUserUseCase>(),
      ),
    );
    gh.factory<_i561.ChatBloc>(
      () => _i561.ChatBloc(
        gh<_i548.ChatWsDataSource>(),
        gh<_i350.GetMessagesUseCase>(),
      ),
    );
    gh.factory<_i748.AdminBloc>(
      () => _i748.AdminBloc(
        gh<_i972.GetPlatformStatsUseCase>(),
        gh<_i525.GetAdminUsersUseCase>(),
        gh<_i414.UpdateUserStatusUseCase>(),
        gh<_i402.GetAlertsUseCase>(),
        gh<_i277.ResolveAlertUseCase>(),
      ),
    );
    gh.factory<_i567.ErrorBookBloc>(
      () => _i567.ErrorBookBloc(
        gh<_i314.GetErrorBookUseCase>(),
        gh<_i266.ReviewErrorUseCase>(),
      ),
    );
    return this;
  }
}

class _$ConnectivityModule extends _i75.ConnectivityModule {}

class _$NetworkModule extends _i871.NetworkModule {}
