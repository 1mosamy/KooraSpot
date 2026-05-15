import 'package:equatable/equatable.dart';

import '../../../slots/domain/entities/slot.dart';
import '../../../courts/domain/entities/court.dart';

/// Booking status enum.
enum BookingStatus { upcoming, past, cancelled, confirmed }

/// Booking entity.
class Booking extends Equatable {
  final String id;
  final Court court;
  final DateTime date;
  final List<Slot> selectedSlots;
  final double totalPrice;
  final String currency;
  final BookingStatus status;

  const Booking({
    required this.id,
    required this.court,
    required this.date,
    required this.selectedSlots,
    required this.totalPrice,
    this.currency = 'EGP',
    this.status = BookingStatus.upcoming,
  });

  String get formattedPrice => '${totalPrice.toInt()} $currency';
  String get slotCount => '${selectedSlots.length} slot${selectedSlots.length > 1 ? 's' : ''}';

  @override
  List<Object?> get props => [id, court, date, selectedSlots, totalPrice, status];
}
