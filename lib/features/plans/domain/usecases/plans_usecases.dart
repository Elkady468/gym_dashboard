import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/plan_entity.dart';
import '../repositories/plans_repository.dart';

class GetPlansUseCase    { final PlansRepository _r; GetPlansUseCase(this._r);    Future<Either<Failure, List<PlanEntity>>> call() => _r.getPlans(); }
class CreatePlanUseCase  { final PlansRepository _r; CreatePlanUseCase(this._r);  Future<Either<Failure, PlanEntity>> call(Map<String, dynamic> d) => _r.createPlan(d); }
class UpdatePlanUseCase  { final PlansRepository _r; UpdatePlanUseCase(this._r);  Future<Either<Failure, PlanEntity>> call(int id, Map<String, dynamic> d) => _r.updatePlan(id, d); }
class DeletePlanUseCase  { final PlansRepository _r; DeletePlanUseCase(this._r);  Future<Either<Failure, void>> call(int id) => _r.deletePlan(id); }
