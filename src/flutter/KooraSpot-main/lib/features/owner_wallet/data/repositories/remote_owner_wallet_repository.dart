import 'package:dio/dio.dart';

import '../../../../app/constants/api_constants.dart';
import '../../../../core/network/api_error.dart';
import '../../domain/repositories/owner_wallet_repository.dart';
import '../models/owner_wallet_models.dart';

/// Dio-based implementation of [OwnerWalletRepository].
class RemoteOwnerWalletRepository implements OwnerWalletRepository {
  final Dio _dio;

  RemoteOwnerWalletRepository({required Dio dio}) : _dio = dio;

  @override
  Future<OwnerWalletSummary> getSummary() async {
    try {
      final response = await _dio.get(ApiConstants.ownerWalletSummary);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return OwnerWalletSummary.fromJson(data);
      }
      // If the API returns a wrapper, try to unwrap
      if (data is Map && data.containsKey('data')) {
        return OwnerWalletSummary.fromJson(
            data['data'] as Map<String, dynamic>);
      }
      return OwnerWalletSummary.empty;
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<void> withdraw({
    required num amount,
    required String walletNumber,
  }) async {
    try {
      await _dio.post(
        ApiConstants.ownerWalletWithdraw,
        data: {
          'amount': amount,
          'walletNumber': walletNumber,
        },
      );
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<List<OwnerWithdrawalModel>> getWithdrawals() async {
    try {
      final response = await _dio.get(ApiConstants.ownerWalletWithdrawals);
      final data = response.data;

      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('data') && data['data'] is List) {
        list = data['data'] as List;
      } else {
        return [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map(OwnerWithdrawalModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }
}
