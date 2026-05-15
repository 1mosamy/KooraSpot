import 'package:equatable/equatable.dart';

/// Court/Stadium entity.
class Court extends Equatable {
  final String id;
  final String name;
  final String location;
  final String city;
  final String? distanceText;
  final double pricePerHour;
  final String currency;
  final String imageUrl;
  final bool isSaved;
  final bool isOpen;
  final String type; // e.g. '5v5 Football'
  final String? ownerId;
  final bool isActive;

  const Court({
    required this.id,
    required this.name,
    required this.location,
    required this.city,
    this.distanceText,
    required this.pricePerHour,
    this.currency = 'EGP',
    required this.imageUrl,
    this.isSaved = false,
    this.isOpen = true,
    this.type = '5v5 Football',
    this.ownerId,
    this.isActive = true,
  });

  Court copyWith({
    String? id,
    String? name,
    String? location,
    String? city,
    String? distanceText,
    double? pricePerHour,
    String? currency,
    String? imageUrl,
    bool? isSaved,
    bool? isOpen,
    String? type,
    String? ownerId,
    bool? isActive,
  }) {
    return Court(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      city: city ?? this.city,
      distanceText: distanceText ?? this.distanceText,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      currency: currency ?? this.currency,
      imageUrl: imageUrl ?? this.imageUrl,
      isSaved: isSaved ?? this.isSaved,
      isOpen: isOpen ?? this.isOpen,
      type: type ?? this.type,
      ownerId: ownerId ?? this.ownerId,
      isActive: isActive ?? this.isActive,
    );
  }

  String get formattedPrice => '${pricePerHour.toInt()} $currency/hr';

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        city,
        distanceText,
        pricePerHour,
        currency,
        imageUrl,
        isSaved,
        isOpen,
        type,
        ownerId,
        isActive,
      ];
}
