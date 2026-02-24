import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

@injectable
class GetMessagesUseCase {
  final ChatRepository _repository;

  GetMessagesUseCase(this._repository);

  Future<Either<Failure, ({List<Message> messages, int total})>> call(
    String conversationId, {
    int page = 1,
    int size = 20,
  }) =>
      _repository.getMessages(conversationId, page: page, size: size);
}
