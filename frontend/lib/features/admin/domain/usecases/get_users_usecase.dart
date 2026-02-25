import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_summary.dart';
import '../repositories/admin_repository.dart';

@injectable
class GetAdminUsersUseCase {
  GetAdminUsersUseCase(this._repository);
  final AdminRepository _repository;

  Future<Either<Failure, ({List<UserSummary> users, int total})>> call({
    int page = 1,
    int size = 20,
    String? role,
  }) =>
      _repository.getUsers(page: page, size: size, role: role);
}
