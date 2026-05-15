import 'package:equatable/equatable.dart';

/// Slot status enum for time slot chips.
enum SlotStatus { available, selected, booked, unavailable }

/// Time slot entity.
class Slot extends Equatable {
  final String id;
  final String courtId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final SlotStatus status;
  final String? bookedByName;

  const Slot({
    required this.id,
    required this.courtId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = SlotStatus.available,
    this.bookedByName,
  });

  String get timeRange => '$startTime - $endTime';

  bool get isAvailable => status == SlotStatus.available;
  bool get isSelected => status == SlotStatus.selected;
  bool get isBooked => status == SlotStatus.booked;
  bool get isUnavailable => status == SlotStatus.unavailable;

  Slot copyWith({
    String? id,
    String? courtId,
    DateTime? date,
    String? startTime,
    String? endTime,
    SlotStatus? status,
    String? bookedByName,
  }) {
    return Slot(
      id: id ?? this.id,
      courtId: courtId ?? this.courtId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      bookedByName: bookedByName ?? this.bookedByName,
    );
  }

  @override
  List<Object?> get props =>
      [id, courtId, date, startTime, endTime, status, bookedByName];
}
