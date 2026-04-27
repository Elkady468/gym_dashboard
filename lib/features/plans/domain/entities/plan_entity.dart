import 'package:equatable/equatable.dart';

class PlanEntity extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;
  final int durationDays;

  const PlanEntity({
    required this.id, required this.name, required this.description,
    required this.price, required this.durationDays,
  });

  @override
  List<Object> get props => [id, name, price, durationDays];
}
