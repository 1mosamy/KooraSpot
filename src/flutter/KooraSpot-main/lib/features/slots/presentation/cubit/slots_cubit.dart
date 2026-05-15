import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/slot.dart';
import '../../domain/repositories/slot_repository.dart';

part 'slots_state.dart';

class SlotsCubit extends Cubit<SlotsState> {
  final SlotRepository _slotRepository;

  SlotsCubit({required SlotRepository slotRepository})
      : _slotRepository = slotRepository,
        super(const SlotsInitial());

  List<Slot> _slots = [];
  String _courtId = '';
  DateTime _selectedDate = DateTime.now();

  Future<void> loadSlots(String courtId, DateTime date) async {
    _courtId = courtId;
    _selectedDate = date;
    emit(const SlotsLoading());
    try {
      _slots = await _slotRepository.getSlotsByCourtAndDate(
        courtId: courtId,
        date: date,
      );
      emit(SlotsLoaded(slots: _slots));
    } catch (e) {
      emit(SlotsFailure(message: e.toString()));
    }
  }

  void toggleAvailability(String slotId) {
    _slots = _slots.map((slot) {
      if (slot.id == slotId && !slot.isBooked) {
        return slot.copyWith(
          status: slot.isAvailable ? SlotStatus.unavailable : SlotStatus.available,
        );
      }
      return slot;
    }).toList();
    emit(SlotsLoaded(slots: _slots));
  }

  Future<void> saveChanges() async {
    emit(const SlotsSaving());
    try {
      await _slotRepository.saveSlotChanges(
        courtId: _courtId,
        date: _selectedDate,
        slots: _slots,
      );
      emit(const SlotsSaved());
      // Refresh after save
      await loadSlots(_courtId, _selectedDate);
    } catch (e) {
      emit(SlotsFailure(message: e.toString()));
    }
  }
}
