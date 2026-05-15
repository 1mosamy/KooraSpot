import '../../../slots/domain/entities/slot.dart';

/// Slot repository interface.
abstract class SlotRepository {
  Future<List<Slot>> getSlotsByCourtAndDate({
    required String courtId,
    required DateTime date,
  });

  Future<void> saveSlotChanges({
    required String courtId,
    required DateTime date,
    required List<Slot> slots,
  });
}
