import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/create_conversation_model.dart';

@Injectable(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Conversation>> createConversation({
    required String agentType,
    String? personaId,
    String? title,
  }) async {
    try {
      final model = await _remoteDataSource.createConversation(
        CreateConversationModel(
          agentType: agentType,
          personaId: personaId,
          title: title,
        ),
      );
      return Right(Conversation(
        id: model.id,
        agentType: model.agentType,
        personaId: model.personaId,
        title: model.title,
        status: model.status,
        messageCount: model.messageCount,
        lastMessageAt: model.lastMessageAt,
        createdAt: model.createdAt,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Conversation>>> listConversations({
    int page = 1,
    int size = 20,
  }) async {
    try {
      final models = await _remoteDataSource.listConversations(
        page: page,
        size: size,
      );
      return Right(models
          .map((m) => Conversation(
                id: m.id,
                agentType: m.agentType,
                personaId: m.personaId,
                title: m.title,
                status: m.status,
                messageCount: m.messageCount,
                lastMessageAt: m.lastMessageAt,
                createdAt: m.createdAt,
              ))
          .toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({List<Message> messages, int total})>> getMessages(
    String conversationId, {
    int page = 1,
    int size = 20,
  }) async {
    try {
      final model = await _remoteDataSource.getMessages(
        conversationId,
        page: page,
        size: size,
      );
      final messages = model.messages
          .map((m) => Message(
                id: m.id,
                role: m.role,
                contentType: m.contentType,
                content: m.content,
                emotionLabel: m.emotionLabel,
                intentLabel: m.intentLabel,
                tokenCount: m.tokenCount,
                createdAt: m.createdAt,
              ))
          .toList();
      return Right((messages: messages, total: model.total));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(
    String conversationId,
  ) async {
    try {
      await _remoteDataSource.deleteConversation(conversationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
