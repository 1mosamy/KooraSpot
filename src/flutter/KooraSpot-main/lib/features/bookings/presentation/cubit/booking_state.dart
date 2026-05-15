part of 'booking_cubit.dart';

sealed class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object?> get props => [];
}

// ── Slot states (Stadium Details) ────────────────────

class BookingInitial extends BookingState {
  const BookingInitial();
}

/// Generic loading — used for slot loading and booking confirmation.
class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingSlotsLoaded extends BookingState {
  final List<Slot> slots;
  final DateTime selectedDate;
  const BookingSlotsLoaded({required this.slots, required this.selectedDate});
  @override
  List<Object?> get props => [slots, selectedDate];
}

class BookingConfirming extends BookingState {
  const BookingConfirming();
}

class BookingCreated extends BookingState {
  final CreateBookingResponse response;
  const BookingCreated({required this.response});
  @override
  List<Object?> get props => [response];
}

/// Emitted when the Stripe checkout URL is ready to open.
class BookingPaymentReady extends BookingState {
  final String paymentUrl;
  final String? sessionId;
  const BookingPaymentReady({required this.paymentUrl, this.sessionId});
  @override
  List<Object?> get props => [paymentUrl, sessionId];
}

class BookingFailure extends BookingState {
  final String message;
  const BookingFailure({required this.message});
  @override
  List<Object?> get props => [message];
}

// ── Booking History states (separate — do NOT affect slot UI) ─

/// Loading state specifically for booking history.
/// Does NOT overwrite slots — the stadium screen ignores this.
class BookingHistoryLoading extends BookingState {
  const BookingHistoryLoading();
}

class BookingHistoryLoaded extends BookingState {
  final List<PlayerBookingModel> bookings;
  const BookingHistoryLoaded({required this.bookings});
  @override
  List<Object?> get props => [bookings];
}

class BookingHistoryFailure extends BookingState {
  final String message;
  const BookingHistoryFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
