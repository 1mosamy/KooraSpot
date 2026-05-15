import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../courts/domain/entities/court.dart';
import '../../../owner_dashboard/domain/entities/owner_stats.dart';
import '../../domain/repositories/owner_fields_repository.dart';

part 'owner_fields_state.dart';

class OwnerFieldsCubit extends Cubit<OwnerFieldsState> {
  final OwnerFieldsRepository _repository;

  /// In-memory cache so we can do optimistic updates without losing the list.
  List<Court> _cachedFields = [];
  OwnerStats _cachedStats = const OwnerStats(
    todayBookings: 0,
    weeklyRevenue: 0,
    courtsCount: 0,
  );

  OwnerFieldsCubit({required OwnerFieldsRepository repository})
      : _repository = repository,
        super(const OwnerFieldsInitial());

  // ── Helpers ──────────────────────────────────────────────────────────────

  OwnerFieldsLoaded get _loadedState =>
      OwnerFieldsLoaded(fields: _cachedFields, stats: _cachedStats);

  // ── Load ─────────────────────────────────────────────────────────────────

  Future<void> loadFields() async {
    emit(const OwnerFieldsLoading());
    try {
      final fields = await _repository.getOwnerFields();
      final stats = await _repository.getOwnerStats();
      _cachedFields = fields;
      _cachedStats = stats;
      emit(_loadedState);
    } catch (e) {
      emit(OwnerFieldsFailure(message: e.toString()));
    }
  }

  // ── Add ──────────────────────────────────────────────────────────────────

  Future<void> addCourt({
    required String name,
    required String address,
    required String city,
    required double pricePerHour,
    String? description,
    List<File>? images,
  }) async {
    emit(const OwnerFieldsLoading());
    try {
      await _repository.addCourt(
        name: name,
        address: address,
        city: city,
        pricePerHour: pricePerHour,
        description: description,
        images: images,
      );
      emit(const OwnerFieldAdded());
      await loadFields();
    } catch (e) {
      emit(OwnerFieldsFailure(message: e.toString()));
    }
  }

  // ── Update ───────────────────────────────────────────────────────────────

  Future<void> updateField({
    required int fieldId,
    required String name,
    required String address,
    required String city,
    required double pricePerHour,
    String? description,
    List<File>? images,
  }) async {
    emit(const OwnerFieldUpdating());
    try {
      await _repository.updateField(
        fieldId: fieldId,
        name: name,
        address: address,
        city: city,
        pricePerHour: pricePerHour,
        description: description,
        images: images,
      );
      emit(const OwnerFieldUpdated());
      await loadFields();
    } catch (e) {
      emit(OwnerFieldsFailure(
          message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // ── Toggle Active ─────────────────────────────────────────────────────────
  //
  // Strategy: optimistic update.
  // 1. Immediately flip isActive in the cached list and emit so the card
  //    stays visible with the correct new state.
  // 2. Mark the field as "toggling" so only that switch shows a spinner.
  // 3. Call the API in the background.
  // 4. On success → clear the spinner.
  // 5. On failure → revert the optimistic flip and show an error.
  //
  // This means the field is ALWAYS visible, whether active or inactive.

  Future<void> toggleFieldActive(int fieldId) async {
    // --- 1. Optimistic flip ---
    final prevFields = List<Court>.from(_cachedFields);
    _cachedFields = _cachedFields.map((f) {
      if (int.tryParse(f.id) == fieldId) {
        return f.copyWith(isActive: !f.isActive);
      }
      return f;
    }).toList();

    // Show updated list with spinner on this field's switch
    emit(OwnerFieldsLoaded(
      fields: _cachedFields,
      stats: _cachedStats,
      togglingFieldId: fieldId,
    ));

    // --- 2. API call ---
    try {
      await _repository.toggleFieldActive(fieldId);
      // Success → clear spinner (keep optimistic flip)
      emit(_loadedState);
    } catch (e) {
      // Failure → revert optimistic flip
      _cachedFields = prevFields;
      emit(OwnerFieldsLoaded(
        fields: _cachedFields,
        stats: _cachedStats,
      ));
      emit(OwnerFieldsFailure(
          message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteField(int fieldId) async {
    emit(const OwnerFieldDeleting());
    try {
      await _repository.deleteField(fieldId);
      emit(const OwnerFieldDeleted());
      await loadFields();
    } catch (e) {
      emit(OwnerFieldsFailure(
          message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
