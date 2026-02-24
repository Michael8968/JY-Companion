import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String username, String password);

  Future<Either<Failure, User>> register({
    required String username,
    required String password,
    required String displayName,
    String role = 'student',
    String? email,
    String? phone,
    String? grade,
    String? className,
    String? studentId,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();
}
