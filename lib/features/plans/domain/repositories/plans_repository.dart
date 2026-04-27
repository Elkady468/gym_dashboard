import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/plan_entity.dart';

abstract class PlansRepository {
  Future<Either<Failure, List<PlanEntity>>> getPlans();
  Future<Either<Failure, PlanEntity>> createPlan(Map<String, dynamic> data);
  Future<Either<Failure, PlanEntity>> updatePlan(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deletePlan(int id);
}
