import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_repository.dart';

@injectable
class UpdateUserStatusUseCase {
  UpdateUserStatusUseCase(this._repository);
  final AdminRepository _repository;

  Future<Either<Failure, void>> call(String userId, bool isActive) =>
      _repository.updateUserStatus(userId, isActive);
}
