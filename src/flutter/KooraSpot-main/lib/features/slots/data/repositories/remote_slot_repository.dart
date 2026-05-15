import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../app/constants/api_constants.dart';
import '../../../../core/network/api_error.dart';
import '../../domain/entities/slot.dart';
import '../../domain/repositories/slot_repository.dart';
import '../models/slot_model.dart';

/// Real slot repository using Dio.
class RemoteSlotRepository implements SlotRepository {
  final Dio _dio;

  RemoteSlotRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<Slot>> getSlotsByCourtAndDate({
    required String courtId,
    required DateTime date,
  }) async {
    try {
      final fieldId = int.parse(courtId);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final response = await _dio.get(
        ApiConstants.fieldSlots(fieldId),
        queryParameters: {'date': dateStr},
      );
      final list = (response.data as List<dynamic>?) ?? [];
      return list
          .map((e) => SlotModel.fromJson(e as Map<String, dynamic>).toEntity(courtId))
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<void> saveSlotChanges({
    required String courtId,
    required DateTime date,
    required List<Slot> slots,
  }) async {
    try {
      final fieldId = int.parse(courtId);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final body = slots.map((s) => {
            'slotTime': s.timeRange,
            'isActive': s.isAvailable || s.isSelected,
          }).toList();
      await _dio.put(
        ApiConstants.fieldSlots(fieldId),
        queryParameters: {'date': dateStr},
        data: body,
      );
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }
}
