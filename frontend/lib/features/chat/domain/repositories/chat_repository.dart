import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<Either<Failure, Conversation>> createConversation({
    required String agentType,
    String? personaId,
    String? title,
  });

  Future<Either<Failure, List<Conversation>>> listConversations({
    int page = 1,
    int size = 20,
  });

  Future<Either<Failure, ({List<Message> messages, int total})>> getMessages(
    String conversationId, {
    int page = 1,
    int size = 20,
  });

  Future<Either<Failure, void>> deleteConversation(String conversationId);
}
