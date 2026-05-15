import '../../domain/entities/user.dart';

/// User model with JSON serialization for the data layer.
class UserModel {
  final String? id;
  final String name;          // API field: "name"
  final String email;
  final String role;
  final String? city;
  final String? phonenumber;  // API field: "phonenumber"
  final String? token;
  final String? profileImageUrl;
  final String? firstLetter;  // API field: "firstLetter"

  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // API returns {"token": "...", "user": {...}}
    final userData = json['user'] as Map<String, dynamic>? ?? json;
    final token = json['token'] as String? ?? userData['token'] as String?;

    // Debug log
    // ignore: avoid_print
    print('[UserModel.fromJson] name=${userData['name']} email=${userData['email']} '
        'role=${userData['role']} city=${userData['city']} '
        'phonenumber=${userData['phonenumber']} '
        'profileImageUrl=${userData['profileImageUrl']} '
        'firstLetter=${userData['firstLetter']}');

    return UserModel(
      id: userData['id']?.toString(),
      // Login response: "name" | Register/Update response: "fullName"
      name: userData['name'] as String? ?? userData['fullName'] as String? ?? '',
      email: userData['email'] as String? ?? '',
      role: userData['role'] as String? ?? 'Player',
      city: userData['city'] as String?,
      // Login response: "phonenumber" | Update response: "phoneNumber"
      phonenumber: userData['phonenumber'] as String? ?? userData['phoneNumber'] as String?,
      token: token,
      profileImageUrl: userData['profileImageUrl'] as String?,
      firstLetter: userData['firstLetter'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'role': role,
      if (city != null) 'city': city,
      if (phonenumber != null) 'phonenumber': phonenumber,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (firstLetter != null) 'firstLetter': firstLetter,
    };
  }

  UserModel copyWith({
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
    return UserModel(
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

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      role: role,
      city: city,
      phonenumber: phonenumber,
      token: token,
      profileImageUrl: profileImageUrl,
      firstLetter: firstLetter,
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      city: user.city,
      phonenumber: user.phonenumber,
      token: user.token,
      profileImageUrl: user.profileImageUrl,
      firstLetter: user.firstLetter,
    );
  }
}
