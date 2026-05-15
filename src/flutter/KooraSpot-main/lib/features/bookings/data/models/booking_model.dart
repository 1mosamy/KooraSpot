/// Request body for POST /api/Bookings.
class CreateBookingRequest {
  final int fieldId;
  final String bookingDate;
  final List<String> slotTime;

  const CreateBookingRequest({
    required this.fieldId,
    required this.bookingDate,
    required this.slotTime,
  });

  Map<String, dynamic> toJson() => {
        'fieldId': fieldId,
        'bookingDate': bookingDate,
        'slotTime': slotTime,
      };
}

/// Response from POST /api/Bookings.
class CreateBookingResponse {
  final String message;
  final List<int> bookingIds;
  final int totalSlots;
  final num totalPrice;

  const CreateBookingResponse({
    required this.message,
    required this.bookingIds,
    required this.totalSlots,
    required this.totalPrice,
  });

  factory CreateBookingResponse.fromJson(Map<String, dynamic> json) {
    return CreateBookingResponse(
      message: json['message'] as String? ?? '',
      bookingIds: (json['bookingIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      totalSlots: json['totalSlots'] as int? ?? 0,
      totalPrice: json['totalPrice'] as num? ?? 0,
    );
  }
}

/// Flat booking model from GET /api/Bookings/my (player view).
class PlayerBookingModel {
  final int id;
  final String fieldName;
  final String slotTime;
  final String bookingDate;
  final String dayName;
  final num totalPrice;
  final String status;

  const PlayerBookingModel({
    required this.id,
    required this.fieldName,
    required this.slotTime,
    required this.bookingDate,
    required this.dayName,
    required this.totalPrice,
    required this.status,
  });

  factory PlayerBookingModel.fromJson(Map<String, dynamic> json) {
    return PlayerBookingModel(
      id: json['id'] as int? ?? 0,
      fieldName: json['fieldName'] as String? ?? '',
      slotTime: json['slotTime'] as String? ?? '',
      bookingDate: json['bookingDate'] as String? ?? '',
      dayName: json['dayName'] as String? ?? '',
      totalPrice: json['totalPrice'] as num? ?? 0,
      status: json['status'] as String? ?? 'Pending',
    );
  }

  /// Whether booking date is today or in the future.
  bool get isUpcoming {
    final d = DateTime.tryParse(bookingDate);
    if (d == null) return false;
    final today = DateTime.now();
    return !d.isBefore(DateTime(today.year, today.month, today.day)) &&
        status != 'Cancelled';
  }
}

/// Flat booking model from GET /api/Bookings/field/{id} (owner view).
class OwnerFieldBookingModel {
  final int id;
  final String playerName;
  final String slotTime;
  final String bookingDate;
  final String dayName;
  final num totalPrice;
  final String status;

  const OwnerFieldBookingModel({
    required this.id,
    required this.playerName,
    required this.slotTime,
    required this.bookingDate,
    required this.dayName,
    required this.totalPrice,
    required this.status,
  });

  factory OwnerFieldBookingModel.fromJson(Map<String, dynamic> json) {
    return OwnerFieldBookingModel(
      id: json['id'] as int? ?? 0,
      playerName: json['playerName'] as String? ?? '',
      slotTime: json['slotTime'] as String? ?? '',
      bookingDate: json['bookingDate'] as String? ?? '',
      dayName: json['dayName'] as String? ?? '',
      totalPrice: json['totalPrice'] as num? ?? 0,
      status: json['status'] as String? ?? 'Pending',
    );
  }
}
