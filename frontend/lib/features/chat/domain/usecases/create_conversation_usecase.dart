import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

@injectable
class CreateConversationUseCase {
  final ChatRepository _repository;

  CreateConversationUseCase(this._repository);

  Future<Either<Failure, Conversation>> call({
    required String agentType,
    String? personaId,
    String? title,
  }) =>
      _repository.createConversation(
        agentType: agentType,
        personaId: personaId,
        title: title,
      );
}
