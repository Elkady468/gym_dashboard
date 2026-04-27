/// Barrel file: data layer for Subscriptions, Workouts, Messaging, Analytics, Attendance
library admin_data_layers;

import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_admin/core/constants/app_constants.dart';
import 'package:gym_admin/core/entities/shared_entities.dart';
import 'package:gym_admin/core/errors/exceptions.dart';
import 'package:gym_admin/core/network/dio_client.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SUBSCRIPTIONS
// ═══════════════════════════════════════════════════════════════════════════════

class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel(
      {required super.id,
      required super.userId,
      required super.username,
      required super.planId,
      required super.planName,
      required super.startDate,
      required super.expiryDate,
      required super.isActive});

  factory SubscriptionModel.fromJson(Map<String, dynamic> j) {
    final planData = j['plan'];
    int planId = 0;
    String planName = '';
    if (planData is Map) {
      planId = planData['id'] as int? ?? 0;
      planName = planData['name'] as String? ?? '';
    } else {
      planId = planData as int? ?? 0;
      planName = j['plan_name'] as String? ?? '';
    }
    final userObj = j['user'];
    int userId = 0;
    String username = '';
    if (userObj is Map) {
      userId = userObj['id'] as int? ?? 0;
      username = userObj['username'] as String? ?? '';
    } else {
      userId = userObj as int? ?? 0;
      username = j['username'] as String? ?? '';
    }
    return SubscriptionModel(
      id: j['id'] as int? ?? 0,
      userId: userId,
      username: username,
      planId: planId,
      planName: planName,
      startDate:
          DateTime.tryParse(j['start_date'] as String? ?? '') ?? DateTime.now(),
      expiryDate: DateTime.tryParse(j['expiry_date'] as String? ?? '') ??
          DateTime.now(),
      isActive: j['is_active'] as bool? ?? false,
    );
  }
}

abstract class SubscriptionsRemoteDS {
  Future<List<SubscriptionModel>> getSubscriptions();
  Future<SubscriptionModel> createSubscription(Map<String, dynamic> data);
  Future<SubscriptionModel> updateSubscription(
      int id, Map<String, dynamic> data);
  Future<void> deleteSubscription(int id);
}

class SubscriptionsRemoteDSImpl implements SubscriptionsRemoteDS {
  final Dio _dio;
  SubscriptionsRemoteDSImpl(this._dio);
  List<SubscriptionModel> _l(dynamic d) {
    final l = d is List ? d : (d['results'] as List? ?? []);
    return l
        .map((e) => SubscriptionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SubscriptionModel>> getSubscriptions() async {
    try {
      return _l((await _dio.get(AppConstants.subscriptionsEndpoint)).data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<SubscriptionModel> createSubscription(
      Map<String, dynamic> data) async {
    try {
      return SubscriptionModel.fromJson(
          (await _dio.post(AppConstants.subscriptionsEndpoint, data: data)).data
              as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<SubscriptionModel> updateSubscription(
      int id, Map<String, dynamic> data) async {
    try {
      return SubscriptionModel.fromJson((await _dio
              .put('${AppConstants.subscriptionsEndpoint}$id/', data: data))
          .data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteSubscription(int id) async {
    try {
      await _dio.delete('${AppConstants.subscriptionsEndpoint}$id/');
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}

// ── Subscriptions Cubit ───────────────────────────────────────────────────────
abstract class SubscriptionsState extends Equatable {
  const SubscriptionsState();
  @override
  List<Object?> get props => [];
}

class SubsInitial extends SubscriptionsState {}

class SubsLoading extends SubscriptionsState {}

class SubsLoaded extends SubscriptionsState {
  final List<SubscriptionEntity> subs;
  const SubsLoaded(this.subs);
  @override
  List<Object> get props => [subs];
}

class SubsError extends SubscriptionsState {
  final String msg;
  const SubsError(this.msg);
  @override
  List<Object> get props => [msg];
}

class SubsActionSuccess extends SubscriptionsState {
  final String msg;
  const SubsActionSuccess(this.msg);
  @override
  List<Object> get props => [msg];
}

class SubscriptionsCubit extends Cubit<SubscriptionsState> {
  final SubscriptionsRemoteDS _ds;
  SubscriptionsCubit(this._ds) : super(SubsInitial());

  Future<void> load() async {
    emit(SubsLoading());
    try {
      emit(SubsLoaded(await _ds.getSubscriptions()));
    } on ServerException catch (e) {
      emit(SubsError(e.message));
    } catch (_) {
      emit(const SubsError('Failed to load subscriptions'));
    }
  }

  Future<void> create(Map<String, dynamic> data) async {
    try {
      await _ds.createSubscription(data);
      emit(const SubsActionSuccess('Subscription created'));
      load();
    } on ServerException catch (e) {
      emit(SubsError(e.message));
    }
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    try {
      await _ds.updateSubscription(id, data);
      emit(const SubsActionSuccess('Subscription updated'));
      load();
    } on ServerException catch (e) {
      emit(SubsError(e.message));
    }
  }

  Future<void> delete(int id) async {
    try {
      await _ds.deleteSubscription(id);
      emit(const SubsActionSuccess('Subscription deleted'));
      load();
    } on ServerException catch (e) {
      emit(SubsError(e.message));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WORKOUTS
// ═══════════════════════════════════════════════════════════════════════════════

class WorkoutPlanModel extends WorkoutPlanEntity {
  const WorkoutPlanModel(
      {required super.id,
      required super.name,
      super.description,
      super.difficulty});
  factory WorkoutPlanModel.fromJson(Map<String, dynamic> j) => WorkoutPlanModel(
      id: j['id'] as int? ?? 0,
      name: j['name'] as String? ?? '',
      description: j['description'] as String?,
      difficulty: j['difficulty'] as String? ?? 'intermediate');
}

class ExerciseModel extends ExerciseEntity {
  const ExerciseModel(
      {required super.id,
      required super.name,
      required super.sets,
      required super.reps,
      required super.restSeconds,
      super.description,
      required super.planId});
  factory ExerciseModel.fromJson(Map<String, dynamic> j, {int planId = 0}) =>
      ExerciseModel(
          id: j['id'] as int? ?? 0,
          name: j['name'] as String? ?? '',
          sets: j['sets'] as int? ?? 3,
          reps: j['reps'] as int? ?? 10,
          restSeconds:
              j['rest_time'] as int? ?? j['rest_seconds'] as int? ?? 60,
          description: j['description'] as String?,
          planId: planId);
}

class AssignmentModel extends AssignmentEntity {
  const AssignmentModel(
      {required super.id,
      required super.userId,
      required super.username,
      required super.plan,
      required super.assignedDate});
  factory AssignmentModel.fromJson(Map<String, dynamic> j) {
    final planData = j['plan'] ?? j['workout_plan'];
    final plan = planData is Map<String, dynamic>
        ? WorkoutPlanModel.fromJson(planData)
        : WorkoutPlanModel(id: planData as int? ?? 0, name: '');
    final userObj = j['user'];
    int userId = 0;
    String username = '';
    if (userObj is Map) {
      userId = userObj['id'] as int? ?? 0;
      username = userObj['username'] as String? ?? '';
    } else {
      userId = userObj as int? ?? 0;
      username = j['username'] as String? ?? '';
    }
    return AssignmentModel(
        id: j['id'] as int? ?? 0,
        userId: userId,
        username: username,
        plan: plan,
        assignedDate: DateTime.tryParse(j['assigned_date'] as String? ?? '') ??
            DateTime.now());
  }
}

abstract class WorkoutsRemoteDS {
  Future<List<WorkoutPlanModel>> getPlans();
  Future<WorkoutPlanModel> createPlan(Map<String, dynamic> d);
  Future<WorkoutPlanModel> updatePlan(int id, Map<String, dynamic> d);
  Future<void> deletePlan(int id);
  Future<List<ExerciseModel>> getExercises(int planId);
  Future<ExerciseModel> createExercise(int planId, Map<String, dynamic> d);
  Future<void> deleteExercise(int planId, int exerciseId);
  Future<List<AssignmentModel>> getAssignments();
  Future<AssignmentModel> createAssignment(Map<String, dynamic> d);
  Future<void> deleteAssignment(int id);
}

class WorkoutsRemoteDSImpl implements WorkoutsRemoteDS {
  final Dio _dio;
  WorkoutsRemoteDSImpl(this._dio);
  List<T> _l<T>(dynamic d, T Function(Map<String, dynamic>) f) {
    final l = d is List ? d : (d['results'] as List? ?? []);
    return l.map((e) => f(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<WorkoutPlanModel>> getPlans() async {
    try {
      return _l((await _dio.get(AppConstants.workoutPlansEndpoint)).data,
          WorkoutPlanModel.fromJson);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<WorkoutPlanModel> createPlan(Map<String, dynamic> d) async {
    try {
      return WorkoutPlanModel.fromJson(
          (await _dio.post(AppConstants.workoutPlansEndpoint, data: d)).data
              as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<WorkoutPlanModel> updatePlan(int id, Map<String, dynamic> d) async {
    try {
      return WorkoutPlanModel.fromJson(
          (await _dio.put('${AppConstants.workoutPlansEndpoint}$id/', data: d))
              .data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deletePlan(int id) async {
    try {
      await _dio.delete('${AppConstants.workoutPlansEndpoint}$id/');
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<List<ExerciseModel>> getExercises(int planId) async {
    try {
      return _l(
          (await _dio.get(
                  '${AppConstants.workoutPlansEndpoint}$planId/exercises/'))
              .data,
          (j) => ExerciseModel.fromJson(j, planId: planId));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<ExerciseModel> createExercise(
      int planId, Map<String, dynamic> d) async {
    try {
      return ExerciseModel.fromJson(
          (await _dio.post(
                  '${AppConstants.workoutPlansEndpoint}$planId/exercises/',
                  data: d))
              .data as Map<String, dynamic>,
          planId: planId);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteExercise(int planId, int exId) async {
    try {
      await _dio.delete(
          '${AppConstants.workoutPlansEndpoint}$planId/exercises/$exId/');
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<List<AssignmentModel>> getAssignments() async {
    try {
      return _l((await _dio.get(AppConstants.workoutAssignmentsEndpoint)).data,
          AssignmentModel.fromJson);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<AssignmentModel> createAssignment(Map<String, dynamic> d) async {
    try {
      return AssignmentModel.fromJson(
          (await _dio.post(AppConstants.workoutAssignmentsEndpoint, data: d))
              .data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteAssignment(int id) async {
    try {
      await _dio.delete('${AppConstants.workoutAssignmentsEndpoint}$id/');
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}

// ── Workouts Cubit ────────────────────────────────────────────────────────────
abstract class WorkoutsState extends Equatable {
  const WorkoutsState();
  @override
  List<Object?> get props => [];
}

class WorkoutsInitial extends WorkoutsState {}

class WorkoutsLoading extends WorkoutsState {}

class WorkoutsLoaded extends WorkoutsState {
  final List<WorkoutPlanEntity> plans;
  final List<AssignmentEntity> assignments;
  final List<ExerciseEntity> exercises;
  final int? selectedPlanId;
  const WorkoutsLoaded(
      {required this.plans,
      required this.assignments,
      this.exercises = const [],
      this.selectedPlanId});
  @override
  List<Object?> get props => [plans, assignments, exercises, selectedPlanId];
}

class WorkoutsError extends WorkoutsState {
  final String msg;
  const WorkoutsError(this.msg);
  @override
  List<Object> get props => [msg];
}

class WorkoutActionSuccess extends WorkoutsState {
  final String msg;
  const WorkoutActionSuccess(this.msg);
  @override
  List<Object> get props => [msg];
}

class WorkoutsCubit extends Cubit<WorkoutsState> {
  final WorkoutsRemoteDS _ds;
  WorkoutsCubit(this._ds) : super(WorkoutsInitial());

  Future<void> load() async {
    emit(WorkoutsLoading());
    try {
      final plans = await _ds.getPlans();
      final assignments = await _ds.getAssignments();
      emit(WorkoutsLoaded(plans: plans, assignments: assignments));
    } on ServerException catch (e) {
      emit(WorkoutsError(e.message));
    } catch (_) {
      emit(const WorkoutsError('Failed to load workouts'));
    }
  }

  Future<void> loadExercises(int planId) async {
    final cur = state;
    if (cur is! WorkoutsLoaded) return;
    try {
      final exercises = await _ds.getExercises(planId);
      emit(WorkoutsLoaded(
          plans: cur.plans,
          assignments: cur.assignments,
          exercises: exercises,
          selectedPlanId: planId));
    } on ServerException catch (e) {
      emit(WorkoutsError(e.message));
    }
  }

  Future<void> createPlan(Map<String, dynamic> d) async {
    try {
      await _ds.createPlan(d);
      emit(const WorkoutActionSuccess('Plan created'));
      load();
    } on ServerException catch (e) {
      emit(WorkoutsError(e.message));
    }
  }

  Future<void> deletePlan(int id) async {
    try {
      await _ds.deletePlan(id);
      emit(const WorkoutActionSuccess('Plan deleted'));
      load();
    } on ServerException catch (e) {
      emit(WorkoutsError(e.message));
    }
  }

  Future<void> createExercise(int planId, Map<String, dynamic> d) async {
    try {
      await _ds.createExercise(planId, d);
      emit(const WorkoutActionSuccess('Exercise added'));
      loadExercises(planId);
    } on ServerException catch (e) {
      emit(WorkoutsError(e.message));
    }
  }

  Future<void> createAssignment(Map<String, dynamic> d) async {
    try {
      await _ds.createAssignment(d);
      emit(const WorkoutActionSuccess('Workout assigned'));
      load();
    } on ServerException catch (e) {
      emit(WorkoutsError(e.message));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MESSAGING
// ═══════════════════════════════════════════════════════════════════════════════

class MessageModel extends MessageEntity {
  const MessageModel(
      {required super.id,
      required super.senderId,
      required super.senderName,
      super.receiverId,
      super.receiverName,
      required super.content,
      required super.sentAt,
      super.isBroadcast});
  factory MessageModel.fromJson(Map<String, dynamic> j) {
    final sender = j['sender'];
    int sId = 0;
    String sName = '';
    if (sender is Map) {
      sId = sender['id'] as int? ?? 0;
      sName = sender['username'] as String? ?? '';
    } else {
      sId = sender as int? ?? 0;
    }
    final receiver = j['receiver'];
    int? rId;
    String? rName;
    if (receiver is Map) {
      rId = receiver['id'] as int?;
      rName = receiver['username'] as String?;
    } else {
      rId = receiver as int?;
    }
    return MessageModel(
        id: j['id'] as int? ?? 0,
        senderId: sId,
        senderName: sName,
        receiverId: rId,
        receiverName: rName,
        content: j['content'] as String? ?? '',
        sentAt: DateTime.tryParse(
                j['sent_at'] as String? ?? j['created_at'] as String? ?? '') ??
            DateTime.now(),
        isBroadcast: j['is_broadcast'] as bool? ?? false);
  }
}

abstract class MessagingRemoteDS {
  Future<List<MessageModel>> getInbox();
  Future<List<MessageModel>> getSent();
  Future<MessageModel> send(Map<String, dynamic> d);
}

class MessagingRemoteDSImpl implements MessagingRemoteDS {
  final Dio _dio;
  MessagingRemoteDSImpl(this._dio);
  List<MessageModel> _l(dynamic d) {
    final l = d is List ? d : (d['results'] as List? ?? []);
    return l
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MessageModel>> getInbox() async {
    try {
      return _l((await _dio.get(AppConstants.inboxEndpoint)).data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<List<MessageModel>> getSent() async {
    try {
      return _l((await _dio.get(AppConstants.sentEndpoint)).data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<MessageModel> send(Map<String, dynamic> d) async {
    try {
      return MessageModel.fromJson(
          (await _dio.post(AppConstants.sendMessageEndpoint, data: d)).data
              as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}

// ── Messaging Cubit ───────────────────────────────────────────────────────────
abstract class MessagingState extends Equatable {
  const MessagingState();
  @override
  List<Object?> get props => [];
}

class MessagingInitial extends MessagingState {}

class MessagingLoading extends MessagingState {}

class MessagingLoaded extends MessagingState {
  final List<MessageEntity> inbox;
  final List<MessageEntity> sent;
  const MessagingLoaded({required this.inbox, required this.sent});
  @override
  List<Object> get props => [inbox, sent];
}

class MessagingError extends MessagingState {
  final String msg;
  const MessagingError(this.msg);
  @override
  List<Object> get props => [msg];
}

class MessageSentSuccess extends MessagingState {}

class MessagingCubit extends Cubit<MessagingState> {
  final MessagingRemoteDS _ds;
  MessagingCubit(this._ds) : super(MessagingInitial());

  Future<void> load() async {
    emit(MessagingLoading());
    try {
      final inbox = await _ds.getInbox();
      final sent = await _ds.getSent();
      emit(MessagingLoaded(inbox: inbox, sent: sent));
    } on ServerException catch (e) {
      emit(MessagingError(e.message));
    } catch (_) {
      emit(const MessagingError('Failed to load messages'));
    }
  }

  Future<void> sendMessage(
      {int? receiverId,
      required String content,
      bool broadcast = false}) async {
    try {
      await _ds.send({
        'receiver': receiverId,
        'content': content,
        'is_broadcast': broadcast
      });
      emit(MessageSentSuccess());
      load();
    } on ServerException catch (e) {
      emit(MessagingError(e.message));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ANALYTICS
// ═══════════════════════════════════════════════════════════════════════════════

class DashboardModel extends DashboardEntity {
  const DashboardModel(
      {required super.activeMembers,
      required super.revenue,
      required super.attendanceCount,
      super.totalMembers,
      super.newMembersThisMonth,
      super.attendanceByDay,
      super.revenueByMonth});
  factory DashboardModel.fromJson(Map<String, dynamic> j) {
    final rawDay = j['attendance_by_day'] as Map<String, dynamic>? ?? {};
    final rawRev = j['revenue_by_month'] as Map<String, dynamic>? ?? {};
    return DashboardModel(
      activeMembers:
          j['active_members'] as int? ?? j['active_members_count'] as int? ?? 0,
      revenue: (j['revenue'] as num?)?.toDouble() ?? 0.0,
      attendanceCount:
          j['attendance_count'] as int? ?? j['total_attendance'] as int? ?? 0,
      totalMembers: j['total_members'] as int? ?? 0,
      newMembersThisMonth: j['new_members_this_month'] as int? ?? 0,
      attendanceByDay:
          rawDay.map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
      revenueByMonth:
          rawRev.map((k, v) => MapEntry(k, (v as num?)?.toDouble() ?? 0.0)),
    );
  }
}

abstract class AnalyticsRemoteDS {
  Future<DashboardModel> getDashboard();
  Future<List<Map<String, dynamic>>> getTrainerStats();
}

class AnalyticsRemoteDSImpl implements AnalyticsRemoteDS {
  final Dio _dio;
  AnalyticsRemoteDSImpl(this._dio);
  @override
  Future<DashboardModel> getDashboard() async {
    try {
      return DashboardModel.fromJson(
          (await _dio.get(AppConstants.dashboardEndpoint)).data
              as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTrainerStats() async {
    try {
      final d = (await _dio.get(AppConstants.trainerStatsEndpoint)).data;
      final l = d is List ? d : (d['results'] as List? ?? []);
      return l.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final DashboardEntity dashboard;
  final List<Map<String, dynamic>> trainerStats;
  const AnalyticsLoaded(
      {required this.dashboard, this.trainerStats = const []});
  @override
  List<Object> get props => [dashboard, trainerStats];
}

class AnalyticsError extends AnalyticsState {
  final String msg;
  const AnalyticsError(this.msg);
  @override
  List<Object> get props => [msg];
}

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRemoteDS _ds;
  AnalyticsCubit(this._ds) : super(AnalyticsInitial());
  Future<void> load() async {
    emit(AnalyticsLoading());
    try {
      final dash = await _ds.getDashboard();
      List<Map<String, dynamic>> stats = [];
      try {
        stats = await _ds.getTrainerStats();
      } catch (_) {}
      emit(AnalyticsLoaded(dashboard: dash, trainerStats: stats));
    } on ServerException catch (e) {
      emit(AnalyticsError(e.message));
    } catch (_) {
      emit(const AnalyticsError('Failed to load analytics'));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ATTENDANCE
// ═══════════════════════════════════════════════════════════════════════════════

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel(
      {required super.id,
      required super.userId,
      required super.username,
      required super.checkIn,
      super.checkOut});
  factory AttendanceModel.fromJson(Map<String, dynamic> j) {
    final userObj = j['user'];
    int userId = 0;
    String username = '';
    if (userObj is Map) {
      userId = userObj['id'] as int? ?? 0;
      username = userObj['username'] as String? ?? '';
    } else {
      userId = userObj as int? ?? 0;
      username = j['username'] as String? ?? '';
    }
    return AttendanceModel(
      id: j['id'] as int? ?? 0,
      userId: userId,
      username: username,
      checkIn: DateTime.tryParse(
              j['check_in'] as String? ?? j['checkin'] as String? ?? '') ??
          DateTime.now(),
      checkOut: j['check_out'] != null
          ? DateTime.tryParse(j['check_out'] as String)
          : j['checkout'] != null
              ? DateTime.tryParse(j['checkout'] as String)
              : null,
    );
  }
}

abstract class AttendanceRemoteDS {
  Future<List<AttendanceModel>> getAttendance({String? date, int? userId});
}

class AttendanceRemoteDSImpl implements AttendanceRemoteDS {
  final Dio _dio;
  AttendanceRemoteDSImpl(this._dio);
  @override
  Future<List<AttendanceModel>> getAttendance(
      {String? date, int? userId}) async {
    try {
      final q = <String, dynamic>{
        if (date != null) 'date': date,
        if (userId != null) 'user': userId
      };
      final d = (await _dio.get(AppConstants.attendanceEndpoint,
              queryParameters: q.isEmpty ? null : q))
          .data;
      final l = d is List ? d : (d['results'] as List? ?? []);
      return l
          .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}

abstract class AttendanceState extends Equatable {
  const AttendanceState();
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceEntity> records;
  const AttendanceLoaded(this.records);
  @override
  List<Object> get props => [records];
}

class AttendanceError extends AttendanceState {
  final String msg;
  const AttendanceError(this.msg);
  @override
  List<Object> get props => [msg];
}

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRemoteDS _ds;
  AttendanceCubit(this._ds) : super(AttendanceInitial());
  Future<void> load({String? date, int? userId}) async {
    emit(AttendanceLoading());
    try {
      emit(AttendanceLoaded(
          await _ds.getAttendance(date: date, userId: userId)));
    } on ServerException catch (e) {
      emit(AttendanceError(e.message));
    } catch (_) {
      emit(const AttendanceError('Failed to load attendance'));
    }
  }
}
