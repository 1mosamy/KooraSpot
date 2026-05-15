import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bookings/data/models/booking_model.dart';
import '../../../bookings/domain/repositories/booking_repository.dart';
import '../../../slots/domain/entities/slot.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _bookingRepository;

  BookingCubit({
    required BookingRepository bookingRepository,
  })  : _bookingRepository = bookingRepository,
        super(const BookingInitial());

  List<Slot> _slots = [];
  DateTime _selectedDate = DateTime.now();
  String _courtId = '';

  // Race condition guard: incremented on each new loadSlots call.
  // Response is only applied if the request ID matches current.
  int _slotsRequestId = 0;

  DateTime get selectedDate => _selectedDate;

  /// Loads slots for [courtId] and [date].
  /// Ignores responses from stale/previous requests.
  Future<void> loadSlots(String courtId, DateTime date) async {
    _courtId = courtId;
    _selectedDate = date;
    // Clear selected slots on date change
    _slots = _slots.map((s) => s.isSelected ? s.copyWith(status: SlotStatus.available) : s).toList();

    // Increment the guard counter before the async call
    final requestId = ++_slotsRequestId;

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    debugPrint('[BookingCubit] loadSlots: courtId=$courtId date=$dateStr requestId=$requestId');

    emit(const BookingLoading());
    try {
      final fieldId = int.parse(courtId);
      final slots = await _bookingRepository.getFieldSlotsByDate(
        fieldId: fieldId,
        date: date,
      );

      // Guard: if another loadSlots was called while we waited, discard this result
      if (_slotsRequestId != requestId) {
        debugPrint('[BookingCubit] Ignoring stale slots response (requestId=$requestId, current=$_slotsRequestId)');
        return;
      }

      // Filter: for player, show active slots and booked slots; hide purely inactive-unbooked
      final visibleSlots = slots.where((s) => s.isAvailable || s.isBooked || s.isSelected).toList();

      debugPrint('[BookingCubit] Slots loaded: total=${slots.length} visible=${visibleSlots.length}');

      _slots = visibleSlots;
      emit(BookingSlotsLoaded(slots: _slots, selectedDate: date));
    } catch (e) {
      if (_slotsRequestId != requestId) return; // discard stale error too
      debugPrint('[BookingCubit] loadSlots error: $e');
      emit(BookingFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void toggleSlotSelection(String slotId) {
    _slots = _slots.map((slot) {
      if (slot.id == slotId && (slot.isAvailable || slot.isSelected)) {
        return slot.copyWith(
          status: slot.isSelected ? SlotStatus.available : SlotStatus.selected,
        );
      }
      return slot;
    }).toList();
    emit(BookingSlotsLoaded(slots: _slots, selectedDate: _selectedDate));
  }

  List<Slot> get selectedSlots =>
      _slots.where((s) => s.isSelected).toList();

  double calculateTotal(double pricePerHour) =>
      selectedSlots.length * pricePerHour;

  /// Creates bookings then initiates Stripe checkout.
  /// Flow: POST /Bookings → POST /Payments/create-checkout-session → emit URL.
  Future<void> confirmBooking(String courtId) async {
    emit(const BookingConfirming());
    try {
      final fieldId = int.parse(courtId);
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final slotTimes = selectedSlots.map((s) => s.timeRange).toList();

      final request = CreateBookingRequest(
        fieldId: fieldId,
        bookingDate: dateStr,
        slotTime: slotTimes,
      );
      final bookingResponse = await _bookingRepository.createBooking(request);

      debugPrint('[BookingCubit] Create booking response bookingIds: ${bookingResponse.bookingIds}');

      // If we have booking IDs, create a Stripe checkout session
      if (bookingResponse.bookingIds.isNotEmpty) {
        try {
          final checkoutResponse = await _bookingRepository
              .createCheckoutSession(bookingResponse.bookingIds);
          if (checkoutResponse.paymentUrl.isNotEmpty) {
            emit(BookingPaymentReady(
              paymentUrl: checkoutResponse.paymentUrl,
              sessionId: checkoutResponse.sessionId,
            ));
            return;
          }
        } catch (_) {
          // If payment session creation fails, still show booking success
        }
      }

      // Fallback: no payment URL — just show booking created
      emit(BookingCreated(response: bookingResponse));
    } catch (e) {
      emit(BookingFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Clears selected slots and reloads from API.
  Future<void> refreshSlots() async {
    if (_courtId.isNotEmpty) {
      await loadSlots(_courtId, _selectedDate);
    }
  }

  // ── Booking History ──────────────────────────────────
  // History is loaded into a SEPARATE state. It does NOT clear
  // _slots or the slots state, so the stadium screen is unaffected.

  List<PlayerBookingModel> _cachedBookings = [];

  /// Loads the player's booking history.
  /// [forceRefresh] — if true, always fetches from API even if cached.
  Future<void> loadMyBookings({bool forceRefresh = false}) async {
    // If already cached and not forced, re-emit cached data
    if (!forceRefresh && _cachedBookings.isNotEmpty) {
      emit(BookingHistoryLoaded(bookings: _cachedBookings));
      return;
    }

    debugPrint('[BookingCubit] Loading my bookings... (forceRefresh=$forceRefresh)');
    // Use a dedicated loading state that does NOT clear slots
    emit(const BookingHistoryLoading());
    try {
      final bookings = await _bookingRepository.getMyBookings();
      debugPrint('[BookingCubit] GET /Bookings/my response count: ${bookings.length}');

      final upcoming = bookings.where((b) => b.isUpcoming).toList();
      final past = bookings.where((b) => !b.isUpcoming).toList();
      debugPrint('[BookingCubit] Upcoming bookings count: ${upcoming.length}');
      debugPrint('[BookingCubit] Past bookings count: ${past.length}');

      _cachedBookings = bookings;
      emit(BookingHistoryLoaded(bookings: bookings));
    } catch (e) {
      emit(BookingHistoryFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
