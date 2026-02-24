import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

@injectable
class DeleteConversationUseCase {
  final ChatRepository _repository;

  DeleteConversationUseCase(this._repository);

  Future<Either<Failure, void>> call(String conversationId) =>
      _repository.deleteConversation(conversationId);
}
