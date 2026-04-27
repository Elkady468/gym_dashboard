import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_admin/core/data/feature_data_layers.dart';
import 'package:gym_admin/core/layout/admin_shell.dart';
import 'package:gym_admin/core/network/dio_client.dart';
import 'package:gym_admin/core/network/token_storage.dart';
import 'package:gym_admin/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:gym_admin/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gym_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_admin/features/auth/domain/usecases/auth_usecases.dart';
import 'package:gym_admin/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gym_admin/features/plans/data/plans_data.dart';
import 'package:gym_admin/features/plans/domain/repositories/plans_repository.dart';
import 'package:gym_admin/features/plans/domain/usecases/plans_usecases.dart';
import 'package:gym_admin/features/plans/presentation/plans_presentation.dart';
import 'package:gym_admin/features/users/data/datasources/users_remote_datasource.dart';
import 'package:gym_admin/features/users/data/repositories/users_repository_impl.dart';
import 'package:gym_admin/features/users/domain/repositories/users_repository.dart';
import 'package:gym_admin/features/users/domain/usecases/users_usecases.dart';
import 'package:gym_admin/features/users/presentation/cubit/users_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── External ──────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // ── Core ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage(sl()));
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl<TokenStorage>()));

  sl.registerLazySingleton<Dio>(() => DioClient.create(
        getAccessToken: () => sl<TokenStorage>().getAccessToken(),
        getRefreshToken: () => sl<TokenStorage>().getRefreshToken(),
        onTokenRefreshed: (a, r) =>
            sl<TokenStorage>().saveTokens(access: a, refresh: r),
        onLogout: () async => sl<TokenStorage>().clearTokens(),
      ));

  // ── Auth ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => GetMeUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerFactory(() => AuthCubit(sl(), sl(), sl(), sl<TokenStorage>()));

  // ── Users ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<UsersRemoteDataSource>(
      () => UsersRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<UsersRepository>(() => UsersRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUserUseCase(sl()));
  sl.registerFactory(() => UsersCubit(sl(), sl(), sl()));

  // ── Plans ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PlansRemoteDataSource>(
      () => PlansRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<PlansRepository>(() => PlansRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetPlansUseCase(sl()));
  sl.registerLazySingleton(() => CreatePlanUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePlanUseCase(sl()));
  sl.registerLazySingleton(() => DeletePlanUseCase(sl()));
  sl.registerFactory(() => PlansCubit(sl(), sl(), sl(), sl()));

  // ── Subscriptions ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<SubscriptionsRemoteDS>(
      () => SubscriptionsRemoteDSImpl(sl()));
  sl.registerFactory(() => SubscriptionsCubit(sl()));

  // ── Workouts ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<WorkoutsRemoteDS>(() => WorkoutsRemoteDSImpl(sl()));
  sl.registerFactory(() => WorkoutsCubit(sl()));

  // ── Messaging ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<MessagingRemoteDS>(
      () => MessagingRemoteDSImpl(sl()));
  sl.registerFactory(() => MessagingCubit(sl()));

  // ── Analytics ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AnalyticsRemoteDS>(
      () => AnalyticsRemoteDSImpl(sl()));
  sl.registerFactory(() => AnalyticsCubit(sl()));

  // ── Attendance ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AttendanceRemoteDS>(
      () => AttendanceRemoteDSImpl(sl()));
  sl.registerFactory(() => AttendanceCubit(sl()));
}
