class UserProfileData {
  const UserProfileData({
    this.name,
    this.email,
    this.avatarUrl,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
  });

  final String? name;
  final String? email;
  final String? avatarUrl;
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;

  bool get isComplete =>
      age != null && gender != null && heightCm != null && weightKg != null;

  factory UserProfileData.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return const UserProfileData();
    }

    return UserProfileData(
      name: _readString(data['name']),
      email: _readString(data['email']),
      avatarUrl: _readString(data['avatar_url']),
      age: _readInt(data['age']),
      gender: _readString(data['gender']),
      heightCm: _readDouble(data['height_cm']),
      weightKg: _readDouble(data['weight_kg']),
    );
  }

  UserProfileData copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
  }) {
    return UserProfileData(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
    );
  }

  static String? _readString(dynamic value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static double? _readDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
