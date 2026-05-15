import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../app/constants/api_constants.dart';
import '../../../../core/network/api_error.dart';
import '../../../slots/domain/entities/slot.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/checkout_session_model.dart';
import '../../domain/repositories/booking_repository.dart';

/// Real booking repository using Dio.
class RemoteBookingRepository implements BookingRepository {
  final Dio _dio;

  RemoteBookingRepository({required Dio dio}) : _dio = dio;

  @override
  Future<CreateBookingResponse> createBooking(CreateBookingRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.bookings,
        data: request.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return CreateBookingResponse.fromJson(data);
      }
      // Plain string success
      return CreateBookingResponse(
        message: data?.toString() ?? 'Booking created',
        bookingIds: [],
        totalSlots: request.slotTime.length,
        totalPrice: 0,
      );
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<List<PlayerBookingModel>> getMyBookings() async {
    try {
      final response = await _dio.get(ApiConstants.myBookings);
      final list = (response.data as List<dynamic>?) ?? [];
      return list
          .map((e) => PlayerBookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<List<OwnerFieldBookingModel>> getFieldBookings(int fieldId) async {
    try {
      final response = await _dio.get(ApiConstants.fieldBookings(fieldId));
      final list = (response.data as List<dynamic>?) ?? [];
      return list
          .map((e) => OwnerFieldBookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<List<Slot>> getFieldSlotsByDate({
    required int fieldId,
    required DateTime date,
  }) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      // GET /api/Fields/{fieldId}/slots?date=yyyy-MM-dd
      final response = await _dio.get(
        ApiConstants.fieldSlots(fieldId),
        queryParameters: {'date': dateStr},
      );

      final list = (response.data as List<dynamic>?) ?? [];
      return list.map((e) {
        final m = e as Map<String, dynamic>;
        final slotTime = m['slotTime'] as String? ?? '';
        final isBooked = m['isBooked'] as bool? ?? false;
        final isActive = m['isActive'] as bool? ?? true;
        final playerName = m['playerName'] as String?;
        final rawDate = m['date'] as String?;

        final parts = slotTime.split(' - ');
        final start = parts.isNotEmpty ? parts[0].trim() : '';
        final end = parts.length > 1 ? parts[1].trim() : '';

        final SlotStatus status;
        if (isBooked) {
          status = SlotStatus.booked;
        } else if (!isActive) {
          status = SlotStatus.unavailable;
        } else {
          status = SlotStatus.available;
        }

        return Slot(
          id: slotTime,
          courtId: fieldId.toString(),
          date: DateTime.tryParse(rawDate ?? '') ?? date,
          startTime: start,
          endTime: end,
          status: status,
          bookedByName: playerName,
        );
      }).toList();
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<CheckoutSessionResponse> createCheckoutSession(
      List<int> bookingIds) async {
    try {
      final response = await _dio.post(
        ApiConstants.createCheckoutSession,
        data: {'bookingIds': bookingIds},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return CheckoutSessionResponse.fromJson(data);
      }
      // Fallback: if the response is just a URL string
      return CheckoutSessionResponse(
        paymentUrl: data?.toString() ?? '',
      );
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }
}
