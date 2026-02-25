import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_repository.dart';

@injectable
class ResolveAlertUseCase {
  ResolveAlertUseCase(this._repository);
  final AdminRepository _repository;

  Future<Either<Failure, void>> call(String alertId, {String? notes}) =>
      _repository.resolveAlert(alertId, notes: notes);
}
