import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../app/constants/api_constants.dart';
import '../../../../core/network/api_error.dart';
import '../../../courts/domain/entities/court.dart';
import '../../../courts/data/models/field_model.dart';
import '../../../owner_dashboard/domain/entities/owner_stats.dart';
import '../../../owner_wallet/data/models/owner_wallet_models.dart';
import '../../domain/repositories/owner_fields_repository.dart';

/// Real owner fields repository using Dio.
class RemoteOwnerFieldsRepository implements OwnerFieldsRepository {
  final Dio _dio;

  int _cachedFieldsCount = 0;

  RemoteOwnerFieldsRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<Court>> getOwnerFields() async {
    try {
      final response = await _dio.get(ApiConstants.myFields);
      final list = (response.data as List<dynamic>?) ?? [];
      final fields = list
          .map((e) => FieldModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
      _cachedFieldsCount = fields.length;
      return fields;
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<OwnerStats> getOwnerStats() async {
    // Fetch real wallet summary for Total Earned
    OwnerWalletSummary walletSummary = OwnerWalletSummary.empty;
    try {
      final response = await _dio.get(ApiConstants.ownerWalletSummary);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        walletSummary = OwnerWalletSummary.fromJson(data);
      } else if (data is Map && data.containsKey('data')) {
        walletSummary = OwnerWalletSummary.fromJson(
            data['data'] as Map<String, dynamic>);
      }
      debugPrint('[OwnerStats] totalBookingsAmount: ${walletSummary.totalBookingsAmount}');
    } catch (e) {
      // Do not crash dashboard if wallet fails — show 0
      debugPrint('[OwnerStats] wallet summary failed: $e');
    }

    return OwnerStats(
      todayBookings: 0,
      weeklyRevenue: walletSummary.totalBookingsAmount.toDouble(),
      courtsCount: _cachedFieldsCount,
    );
  }

  @override
  Future<Court> addCourt({
    required String name,
    required String address,
    required String city,
    required double pricePerHour,
    String? description,
    List<File>? images,
  }) async {
    try {
      final formMap = <String, dynamic>{
        'name': name,
        'address': address,
        'city': city,
        'pricePerHour': pricePerHour,
        if (description != null) 'description': description,
      };

      if (images != null && images.isNotEmpty) {
        final multipartImages = <MultipartFile>[];
        for (final file in images) {
          multipartImages.add(await MultipartFile.fromFile(file.path));
        }
        formMap['images'] = multipartImages;
      }

      await _dio.post(
        ApiConstants.fields,
        data: FormData.fromMap(formMap),
      );

      return Court(
        id: '',
        name: name,
        location: address,
        city: city,
        pricePerHour: pricePerHour,
        imageUrl: '',
      );
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<void> updateField({
    required int fieldId,
    required String name,
    required String address,
    required String city,
    required double pricePerHour,
    String? description,
    List<File>? images,
  }) async {
    try {
      final formMap = <String, dynamic>{
        'Name': name,
        'Address': address,
        'City': city,
        'PricePerHour': pricePerHour,
        if (description != null) 'Description': description,
      };

      if (images != null && images.isNotEmpty) {
        final multipartImages = <MultipartFile>[];
        for (final file in images) {
          multipartImages.add(await MultipartFile.fromFile(file.path));
        }
        formMap['Images'] = multipartImages;
      }

      await _dio.put(
        ApiConstants.updateField(fieldId),
        data: FormData.fromMap(formMap),
      );
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<void> toggleFieldActive(int fieldId) async {
    try {
      await _dio.put(ApiConstants.toggleFieldActive(fieldId));
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<void> deleteField(int fieldId) async {
    try {
      await _dio.delete(ApiConstants.deleteField(fieldId));
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }
}
