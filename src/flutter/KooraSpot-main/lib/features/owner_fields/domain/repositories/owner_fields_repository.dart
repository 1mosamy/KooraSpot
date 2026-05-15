import 'dart:io';

import '../../../courts/domain/entities/court.dart';
import '../../../owner_dashboard/domain/entities/owner_stats.dart';

/// Owner fields repository interface.
abstract class OwnerFieldsRepository {
  Future<List<Court>> getOwnerFields();
  Future<OwnerStats> getOwnerStats();
  Future<Court> addCourt({
    required String name,
    required String address,
    required String city,
    required double pricePerHour,
    String? description,
    List<File>? images,
  });

  /// Update a field via PUT /Fields/{fieldId} (multipart/form-data).
  Future<void> updateField({
    required int fieldId,
    required String name,
    required String address,
    required String city,
    required double pricePerHour,
    String? description,
    List<File>? images,
  });

  /// Toggle active status via PUT /Fields/{fieldId}/toggle-active.
  Future<void> toggleFieldActive(int fieldId);

  /// Delete a field via DELETE /Fields/{fieldId}.
  Future<void> deleteField(int fieldId);
}
