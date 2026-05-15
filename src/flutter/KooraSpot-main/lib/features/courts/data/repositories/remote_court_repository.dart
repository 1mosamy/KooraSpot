import 'package:dio/dio.dart';

import '../../../../app/constants/api_constants.dart';
import '../../../../core/network/api_error.dart';
import '../../domain/entities/court.dart';
import '../../domain/repositories/court_repository.dart';
import '../models/field_model.dart';

/// Real court/fields repository using Dio.
class RemoteCourtRepository implements CourtRepository {
  final Dio _dio;

  RemoteCourtRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<Court>> getNearbyStadiums({String? city, String? query}) async {
    try {
      final response = await _dio.get(ApiConstants.fields);
      final list = (response.data as List<dynamic>?) ?? [];
      var courts = list
          .map((e) =>
              FieldModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();

      // Local search filter
      if (query != null && query.isNotEmpty) {
        courts = courts
            .where(
                (c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      return courts;
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<Court> getCourtById(String id) async {
    try {
      final fieldId = int.parse(id);
      final response = await _dio.get(ApiConstants.fieldById(fieldId));
      return FieldModel.fromJson(response.data as Map<String, dynamic>)
          .toEntity();
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }
}
