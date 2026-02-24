import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

import 'package:jy_companion/core/network/token_manager.dart';
import 'package:jy_companion/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:jy_companion/features/auth/domain/repositories/auth_repository.dart';
import 'package:jy_companion/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jy_companion/features/auth/domain/usecases/login_usecase.dart';
import 'package:jy_companion/features/auth/domain/usecases/logout_usecase.dart';
import 'package:jy_companion/features/auth/domain/usecases/register_usecase.dart';
import 'package:jy_companion/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:jy_companion/features/chat/data/datasources/chat_ws_data_source.dart';
import 'package:jy_companion/features/chat/domain/repositories/chat_repository.dart';
import 'package:jy_companion/features/chat/domain/usecases/create_conversation_usecase.dart';
import 'package:jy_companion/features/chat/domain/usecases/delete_conversation_usecase.dart';
import 'package:jy_companion/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:jy_companion/features/chat/domain/usecases/list_conversations_usecase.dart';
import 'package:jy_companion/features/persona/domain/repositories/persona_repository.dart';
import 'package:jy_companion/features/persona/domain/usecases/bind_persona_usecase.dart';
import 'package:jy_companion/features/persona/domain/usecases/list_bindings_usecase.dart';
import 'package:jy_companion/features/persona/domain/usecases/list_personas_usecase.dart';

// Core mocks
class MockDio extends Mock implements Dio {}

class MockTokenManager extends Mock implements TokenManager {}

// Auth mocks
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

// Chat mocks
class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

class MockChatWsDataSource extends Mock implements ChatWsDataSource {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockCreateConversationUseCase extends Mock
    implements CreateConversationUseCase {}

class MockListConversationsUseCase extends Mock
    implements ListConversationsUseCase {}

class MockGetMessagesUseCase extends Mock implements GetMessagesUseCase {}

class MockDeleteConversationUseCase extends Mock
    implements DeleteConversationUseCase {}

// Persona mocks
class MockPersonaRepository extends Mock implements PersonaRepository {}

class MockListPersonasUseCase extends Mock implements ListPersonasUseCase {}

class MockBindPersonaUseCase extends Mock implements BindPersonaUseCase {}

class MockListBindingsUseCase extends Mock implements ListBindingsUseCase {}
