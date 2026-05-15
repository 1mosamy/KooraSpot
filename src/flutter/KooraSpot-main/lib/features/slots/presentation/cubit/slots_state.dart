part of 'slots_cubit.dart';

sealed class SlotsState extends Equatable {
  const SlotsState();
  @override
  List<Object?> get props => [];
}

class SlotsInitial extends SlotsState {
  const SlotsInitial();
}

class SlotsLoading extends SlotsState {
  const SlotsLoading();
}

class SlotsLoaded extends SlotsState {
  final List<Slot> slots;
  const SlotsLoaded({required this.slots});
  @override
  List<Object?> get props => [slots];
}

class SlotsSaving extends SlotsState {
  const SlotsSaving();
}

class SlotsSaved extends SlotsState {
  const SlotsSaved();
}

class SlotsFailure extends SlotsState {
  final String message;
  const SlotsFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
