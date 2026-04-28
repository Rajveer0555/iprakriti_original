class UserProfileData {
  const UserProfileData({
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
  });

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
      age: _readInt(data['age']),
      gender: data['gender'] as String?,
      heightCm: _readDouble(data['height_cm']),
      weightKg: _readDouble(data['weight_kg']),
    );
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
