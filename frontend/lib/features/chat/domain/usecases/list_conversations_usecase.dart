import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

@injectable
class ListConversationsUseCase {
  final ChatRepository _repository;

  ListConversationsUseCase(this._repository);

  Future<Either<Failure, List<Conversation>>> call({
    int page = 1,
    int size = 20,
  }) =>
      _repository.listConversations(page: page, size: size);
}
