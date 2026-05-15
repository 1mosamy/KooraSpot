import '../../data/models/booking_model.dart';
import '../../data/models/checkout_session_model.dart';
import '../../../slots/domain/entities/slot.dart';

/// Booking repository interface.
abstract class BookingRepository {
  Future<CreateBookingResponse> createBooking(CreateBookingRequest request);
  Future<List<PlayerBookingModel>> getMyBookings();
  Future<List<OwnerFieldBookingModel>> getFieldBookings(int fieldId);

  /// Fetches available & booked slots for a field on a given date.
  /// Uses GET /api/Fields/{fieldId}/slots?date=yyyy-MM-dd
  Future<List<Slot>> getFieldSlotsByDate({
    required int fieldId,
    required DateTime date,
  });

  /// Creates a Stripe checkout session for the given booking IDs.
  Future<CheckoutSessionResponse> createCheckoutSession(List<int> bookingIds);
}
