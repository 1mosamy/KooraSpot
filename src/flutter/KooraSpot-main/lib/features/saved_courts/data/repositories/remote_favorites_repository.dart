import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../app/constants/api_constants.dart';
import '../../../../core/network/api_error.dart';
import '../../../courts/data/models/field_model.dart';
import '../../../courts/domain/entities/court.dart';
import 'favorites_repository.dart';

/// Dio-based implementation of the Favorites API.
class RemoteFavoritesRepository implements FavoritesRepository {
  final Dio _dio;

  RemoteFavoritesRepository({required Dio dio}) : _dio = dio;

  @override
  Future<void> addToFavorites(int fieldId) async {
    try {
      await _dio.post(ApiConstants.favoriteField(fieldId));
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<List<Court>> getMyFavorites() async {
    try {
      final response = await _dio.get(ApiConstants.favorites);
      final data = response.data;

      debugPrint('[Favorites] raw response type: ${data.runtimeType}');
      debugPrint('[Favorites] raw response: $data');

      if (data is List<dynamic>) {
        final courts = data.map((item) {
          // Handle both flat field objects and wrapped { field: {...} }
          final Map<String, dynamic> fieldJson;
          if (item is Map<String, dynamic>) {
            if (item.containsKey('field') && item['field'] is Map) {
              fieldJson = item['field'] as Map<String, dynamic>;
            } else {
              fieldJson = item;
            }
          } else {
            return null;
          }

          debugPrint('[Favorites] parsing fieldJson keys: ${fieldJson.keys.toList()}');
          debugPrint('[Favorites] images raw: ${fieldJson['images']}');

          final model = FieldModel.fromJson(fieldJson);
          debugPrint('[Favorites] parsed images count: ${model.images.length}');
          debugPrint('[Favorites] mainImageUrl: ${model.mainImageUrl}');

          return model.toEntity().copyWith(isSaved: true);
        }).whereType<Court>().toList();

        debugPrint('[Favorites] total courts parsed: ${courts.length}');
        return courts;
      }

      return [];
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<void> removeFromFavorites(int fieldId) async {
    try {
      await _dio.delete(ApiConstants.favoriteField(fieldId));
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }
}
