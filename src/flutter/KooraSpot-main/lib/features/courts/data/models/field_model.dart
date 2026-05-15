import 'package:flutter/foundation.dart';

import '../../../../app/constants/api_constants.dart';
import '../../domain/entities/court.dart';

/// Data model mapping the /api/Fields JSON response to the Court entity.
class FieldModel {
  final int id;
  final String name;
  final String? address;
  final String? city;
  final num pricePerHour;
  final String? description;
  final List<String> images;
  final bool isActive;
  final int? ownerId;

  const FieldModel({
    required this.id,
    required this.name,
    this.address,
    this.city,
    required this.pricePerHour,
    this.description,
    this.images = const [],
    this.isActive = true,
    this.ownerId,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      city: json['city'] as String?,
      pricePerHour: json['pricePerHour'] as num? ?? 0,
      description: json['description'] as String?,
      images: _parseImages(json['images']),
      isActive: json['isActive'] as bool? ?? true,
      ownerId: json['ownerId'] as int?,
    );
  }

  /// Parses the images field which can be:
  /// - List of objects with keys: imageUrl, url, path, imagePath
  /// - List of strings
  /// - null
  static List<String> _parseImages(dynamic raw) {
    if (raw == null || raw is! List) return [];
    final urls = <String>[];
    for (final item in raw) {
      if (item is Map) {
        // Try all known image URL keys
        final url = (item['imageUrl'] ??
                item['url'] ??
                item['path'] ??
                item['imagePath'] ??
                '') as String;
        if (url.isNotEmpty) urls.add(url);
      } else if (item is String && item.isNotEmpty) {
        urls.add(item);
      }
    }
    return urls;
  }

  /// The display location, preferring address over city.
  String get displayLocation => address ?? city ?? '';

  /// The first image URL (normalized) or empty string.
  String get mainImageUrl {
    if (images.isEmpty) return '';
    final normalized = ApiConstants.normalizeImageUrl(images.first) ?? '';
    debugPrint('[FieldModel] mainImageUrl: raw=${images.first} normalized=$normalized');
    return normalized;
  }

  /// Converts this model to the domain Court entity.
  Court toEntity() {
    return Court(
      id: id.toString(),
      name: name,
      location: displayLocation,
      city: city ?? '',
      pricePerHour: pricePerHour.toDouble(),
      imageUrl: mainImageUrl,
      type: '5v5 Football',
      isActive: isActive,
      ownerId: ownerId?.toString(),
    );
  }
}
