import '../../domain/entities/slot.dart';

/// Data model mapping the /api/Fields/{id}/slots JSON response.
class SlotModel {
  final String slotTime;
  final String date;
  final String dayName;
  final bool isActive;
  final bool isBooked;
  final String? playerName;

  const SlotModel({
    required this.slotTime,
    required this.date,
    required this.dayName,
    required this.isActive,
    required this.isBooked,
    this.playerName,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      slotTime: json['slotTime'] as String? ?? '',
      date: json['date'] as String? ?? '',
      dayName: json['dayName'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      isBooked: json['isBooked'] as bool? ?? false,
      playerName: json['playerName'] as String?,
    );
  }

  /// Converts to the domain Slot entity.
  Slot toEntity(String courtId) {
    final parts = slotTime.split(' - ');
    final startTime = parts.isNotEmpty ? parts[0].trim() : '';
    final endTime = parts.length > 1 ? parts[1].trim() : '';

    SlotStatus status;
    if (isBooked) {
      status = SlotStatus.booked;
    } else if (!isActive) {
      status = SlotStatus.unavailable;
    } else {
      status = SlotStatus.available;
    }

    return Slot(
      id: slotTime, // Use slotTime as unique identifier
      courtId: courtId,
      date: DateTime.tryParse(date) ?? DateTime.now(),
      startTime: startTime,
      endTime: endTime,
      status: status,
      bookedByName: playerName,
    );
  }
}
