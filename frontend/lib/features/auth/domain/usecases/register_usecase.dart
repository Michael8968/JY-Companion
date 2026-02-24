import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, User>> call({
    required String username,
    required String password,
    required String displayName,
    String role = 'student',
    String? email,
    String? phone,
    String? grade,
    String? className,
    String? studentId,
  }) =>
      _repository.register(
        username: username,
        password: password,
        displayName: displayName,
        role: role,
        email: email,
        phone: phone,
        grade: grade,
        className: className,
        studentId: studentId,
      );
}
