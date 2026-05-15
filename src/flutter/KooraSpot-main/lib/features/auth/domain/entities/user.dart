import 'package:equatable/equatable.dart';

import '../../../../app/constants/api_constants.dart';

/// User entity for the domain layer.
class User extends Equatable {
  final String? id;
  final String name;         // API field: "name"
  final String email;
  final String role;         // 'Player' or 'Owner'
  final String? city;
  final String? phonenumber; // API field: "phonenumber"
  final String? token;
  final String? profileImageUrl;
  final String? firstLetter; // API field: "firstLetter"

  const User({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    this.city,
    this.phonenumber,
    this.token,
    this.profileImageUrl,
    this.firstLetter,
  });

  // ── Backward-compat alias ─────────────────────────────
  String get fullName => name;

  // ── Helpers ───────────────────────────────────────────
  bool get isPlayer => role == 'Player';
  bool get isOwner => role == 'Owner';

  /// Returns the best single-character initial for avatar fallback.
  String get displayInitial {
    if (firstLetter != null && firstLetter!.isNotEmpty) return firstLetter!;
    if (name.isNotEmpty) return name[0].toUpperCase();
    return '?';
  }

  /// Converts a relative image path returned by the server into an absolute URL.
  /// Returns null if profileImageUrl is null or empty.
  String? get normalizedProfileImageUrl {
    final url = profileImageUrl;
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '${ApiConstants.baseUrl}$url';
    return '${ApiConstants.baseUrl}/$url';
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? city,
    String? phonenumber,
    String? token,
    String? profileImageUrl,
    String? firstLetter,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      city: city ?? this.city,
      phonenumber: phonenumber ?? this.phonenumber,
      token: token ?? this.token,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      firstLetter: firstLetter ?? this.firstLetter,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, email, role, city, phonenumber, token, profileImageUrl, firstLetter];
}
