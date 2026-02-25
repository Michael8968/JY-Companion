import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/evaluate_result.dart';
import '../entities/generate_result.dart';

abstract class CreativeRepository {
  Future<Either<Failure, GenerateResult>> generate({
    required String topic,
    String? style,
  });

  Future<Either<Failure, EvaluateResult>> evaluate({
    required String text,
    String? genre,
  });

  Future<Either<Failure, String>> brainstorm({
    required String context,
    String? stuckPoint,
  });

  Future<Either<Failure, Map<String, dynamic>>> optimize({required String text});
}
