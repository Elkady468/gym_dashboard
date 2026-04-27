import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:gym_admin/features/plans/domain/entities/plan_entity.dart';
import 'package:gym_admin/features/plans/domain/repositories/plans_repository.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';

// ── Model ─────────────────────────────────────────────────────────────────────
class PlanModel extends PlanEntity {
  const PlanModel(
      {required super.id,
      required super.name,
      required super.description,
      required super.price,
      required super.durationDays});

  factory PlanModel.fromJson(Map<String, dynamic> j) => PlanModel(
        id: j['id'] as int? ?? 0,
        name: j['name'] as String? ?? '',
        description: j['description'] as String? ?? '',
        price: (j['price'] as num?)?.toDouble() ?? 0.0,
        durationDays: j['duration_days'] as int? ?? 30,
      );
}

// ── Remote datasource ─────────────────────────────────────────────────────────
abstract class PlansRemoteDataSource {
  Future<List<PlanModel>> getPlans();
  Future<PlanModel> createPlan(Map<String, dynamic> data);
  Future<PlanModel> updatePlan(int id, Map<String, dynamic> data);
  Future<void> deletePlan(int id);
}

class PlansRemoteDataSourceImpl implements PlansRemoteDataSource {
  final Dio _dio;
  PlansRemoteDataSourceImpl(this._dio);

  List<PlanModel> _list(dynamic d) {
    final l = d is List ? d : (d['results'] as List? ?? []);
    return l.map((e) => PlanModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<PlanModel>> getPlans() async {
    try {
      final r = await _dio.get(AppConstants.plansEndpoint);
      return _list(r.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<PlanModel> createPlan(Map<String, dynamic> data) async {
    try {
      final r = await _dio.post(AppConstants.plansEndpoint, data: data);
      return PlanModel.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<PlanModel> updatePlan(int id, Map<String, dynamic> data) async {
    try {
      final r = await _dio.put('${AppConstants.plansEndpoint}$id/', data: data);
      return PlanModel.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deletePlan(int id) async {
    try {
      await _dio.delete('${AppConstants.plansEndpoint}$id/');
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}

// ── Repository impl ───────────────────────────────────────────────────────────
class PlansRepositoryImpl implements PlansRepository {
  final PlansRemoteDataSource _remote;
  PlansRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<PlanEntity>>> getPlans() async {
    try {
      return Right(await _remote.getPlans());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, PlanEntity>> createPlan(
      Map<String, dynamic> data) async {
    try {
      return Right(await _remote.createPlan(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, PlanEntity>> updatePlan(
      int id, Map<String, dynamic> data) async {
    try {
      return Right(await _remote.updatePlan(id, data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deletePlan(int id) async {
    try {
      await _remote.deletePlan(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
