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
import 'features/auth/data/datasources/auth_remote_data_source.dart' as _i767;
import 'features/auth/data/repositories/auth_repository_impl.dart' as _i111;
import 'features/auth/domain/repositories/auth_repository.dart' as _i1015;
import 'features/auth/domain/usecases/get_current_user_usecase.dart' as _i630;
import 'features/auth/domain/usecases/login_usecase.dart' as _i206;
import 'features/auth/domain/usecases/logout_usecase.dart' as _i824;
import 'features/auth/domain/usecases/register_usecase.dart' as _i693;
import 'features/auth/presentation/bloc/auth_bloc.dart' as _i363;
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
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final connectivityModule = _$ConnectivityModule();
    final networkModule = _$NetworkModule();
    gh.singleton<_i895.Connectivity>(() => connectivityModule.connectivity);
    gh.singleton<_i1052.TokenManager>(() => _i1052.TokenManager());
    gh.singleton<_i361.Dio>(() => networkModule.dio(gh<_i1052.TokenManager>()));
    gh.singleton<_i110.AppRouterConfig>(
        () => _i110.AppRouterConfig(gh<_i1052.TokenManager>()));
    gh.factory<_i9.AuthInterceptor>(
        () => _i9.AuthInterceptor(gh<_i1052.TokenManager>()));
    gh.factory<_i548.ChatWsDataSource>(
        () => _i548.ChatWsDataSource(gh<_i1052.TokenManager>()));
    gh.factory<_i767.AuthRemoteDataSource>(
        () => _i767.AuthRemoteDataSource(gh<_i361.Dio>()));
    gh.factory<_i1000.ChatRemoteDataSource>(
        () => _i1000.ChatRemoteDataSource(gh<_i361.Dio>()));
    gh.factory<_i498.PersonaRemoteDataSource>(
        () => _i498.PersonaRemoteDataSource(gh<_i361.Dio>()));
    gh.factory<_i406.PersonaRepository>(
        () => _i348.PersonaRepositoryImpl(gh<_i498.PersonaRemoteDataSource>()));
    gh.factory<_i75.NetworkInfo>(
        () => _i75.NetworkInfoImpl(gh<_i895.Connectivity>()));
    gh.factory<_i165.BindPersonaUseCase>(
        () => _i165.BindPersonaUseCase(gh<_i406.PersonaRepository>()));
    gh.factory<_i592.ListBindingsUseCase>(
        () => _i592.ListBindingsUseCase(gh<_i406.PersonaRepository>()));
    gh.factory<_i244.ListPersonasUseCase>(
        () => _i244.ListPersonasUseCase(gh<_i406.PersonaRepository>()));
    gh.factory<_i453.ChatRepository>(
        () => _i382.ChatRepositoryImpl(gh<_i1000.ChatRemoteDataSource>()));
    gh.factory<_i792.PersonaBloc>(() => _i792.PersonaBloc(
          gh<_i244.ListPersonasUseCase>(),
          gh<_i165.BindPersonaUseCase>(),
          gh<_i592.ListBindingsUseCase>(),
        ));
    gh.factory<_i1015.AuthRepository>(() => _i111.AuthRepositoryImpl(
          gh<_i767.AuthRemoteDataSource>(),
          gh<_i1052.TokenManager>(),
        ));
    gh.factory<_i707.CreateConversationUseCase>(
        () => _i707.CreateConversationUseCase(gh<_i453.ChatRepository>()));
    gh.factory<_i689.DeleteConversationUseCase>(
        () => _i689.DeleteConversationUseCase(gh<_i453.ChatRepository>()));
    gh.factory<_i350.GetMessagesUseCase>(
        () => _i350.GetMessagesUseCase(gh<_i453.ChatRepository>()));
    gh.factory<_i139.ListConversationsUseCase>(
        () => _i139.ListConversationsUseCase(gh<_i453.ChatRepository>()));
    gh.factory<_i630.GetCurrentUserUseCase>(
        () => _i630.GetCurrentUserUseCase(gh<_i1015.AuthRepository>()));
    gh.factory<_i206.LoginUseCase>(
        () => _i206.LoginUseCase(gh<_i1015.AuthRepository>()));
    gh.factory<_i824.LogoutUseCase>(
        () => _i824.LogoutUseCase(gh<_i1015.AuthRepository>()));
    gh.factory<_i693.RegisterUseCase>(
        () => _i693.RegisterUseCase(gh<_i1015.AuthRepository>()));
    gh.factory<_i561.ChatBloc>(() => _i561.ChatBloc(
          gh<_i548.ChatWsDataSource>(),
          gh<_i350.GetMessagesUseCase>(),
        ));
    gh.factory<_i384.ConversationListBloc>(() => _i384.ConversationListBloc(
          gh<_i139.ListConversationsUseCase>(),
          gh<_i707.CreateConversationUseCase>(),
          gh<_i689.DeleteConversationUseCase>(),
        ));
    gh.factory<_i363.AuthBloc>(() => _i363.AuthBloc(
          gh<_i206.LoginUseCase>(),
          gh<_i693.RegisterUseCase>(),
          gh<_i824.LogoutUseCase>(),
          gh<_i630.GetCurrentUserUseCase>(),
        ));
    return this;
  }
}

class _$ConnectivityModule extends _i75.ConnectivityModule {}

class _$NetworkModule extends _i871.NetworkModule {}
