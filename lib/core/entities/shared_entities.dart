import 'package:equatable/equatable.dart';

// ── Subscription ──────────────────────────────────────────────────────────────
class SubscriptionEntity extends Equatable {
  final int id;
  final int userId;
  final String username;
  final int planId;
  final String planName;
  final DateTime startDate;
  final DateTime expiryDate;
  final bool isActive;

  const SubscriptionEntity({
    required this.id, required this.userId, required this.username,
    required this.planId, required this.planName,
    required this.startDate, required this.expiryDate, required this.isActive,
  });

  int get remainingDays {
    final d = expiryDate.difference(DateTime.now()).inDays;
    return d < 0 ? 0 : d;
  }

  @override List<Object> get props => [id, userId, planId, isActive];
}

// ── Workout Plan ──────────────────────────────────────────────────────────────
class WorkoutPlanEntity extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String difficulty;

  const WorkoutPlanEntity({required this.id, required this.name, this.description, this.difficulty = 'intermediate'});
  @override List<Object?> get props => [id, name];
}

class ExerciseEntity extends Equatable {
  final int id;
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? description;
  final int planId;

  const ExerciseEntity({required this.id, required this.name, required this.sets,
    required this.reps, required this.restSeconds, this.description, required this.planId});
  @override List<Object?> get props => [id, name, planId];
}

class AssignmentEntity extends Equatable {
  final int id;
  final int userId;
  final String username;
  final WorkoutPlanEntity plan;
  final DateTime assignedDate;

  const AssignmentEntity({required this.id, required this.userId, required this.username,
    required this.plan, required this.assignedDate});
  @override List<Object> get props => [id, userId, plan];
}

// ── Message ───────────────────────────────────────────────────────────────────
class MessageEntity extends Equatable {
  final int id;
  final int senderId;
  final String senderName;
  final int? receiverId;
  final String? receiverName;
  final String content;
  final DateTime sentAt;
  final bool isBroadcast;

  const MessageEntity({
    required this.id, required this.senderId, required this.senderName,
    this.receiverId, this.receiverName, required this.content,
    required this.sentAt, this.isBroadcast = false,
  });
  @override List<Object?> get props => [id, senderId, receiverId, content];
}

// ── Analytics ─────────────────────────────────────────────────────────────────
class DashboardEntity extends Equatable {
  final int activeMembers;
  final double revenue;
  final int attendanceCount;
  final int totalMembers;
  final int newMembersThisMonth;
  final Map<String, int> attendanceByDay;
  final Map<String, double> revenueByMonth;

  const DashboardEntity({
    required this.activeMembers, required this.revenue, required this.attendanceCount,
    this.totalMembers = 0, this.newMembersThisMonth = 0,
    this.attendanceByDay = const {}, this.revenueByMonth = const {},
  });
  @override List<Object> get props => [activeMembers, revenue, attendanceCount];
}

class TrainerStatsEntity extends Equatable {
  final int trainerId;
  final String trainerName;
  final int assignedMembers;
  final int workoutsCreated;

  const TrainerStatsEntity({required this.trainerId, required this.trainerName,
    required this.assignedMembers, required this.workoutsCreated});
  @override List<Object> get props => [trainerId, assignedMembers];
}

// ── Attendance ────────────────────────────────────────────────────────────────
class AttendanceEntity extends Equatable {
  final int id;
  final int userId;
  final String username;
  final DateTime checkIn;
  final DateTime? checkOut;

  const AttendanceEntity({required this.id, required this.userId,
    required this.username, required this.checkIn, this.checkOut});

  Duration? get duration => checkOut?.difference(checkIn);
  bool get isActive => checkOut == null;
  @override List<Object?> get props => [id, userId, checkIn];
}
