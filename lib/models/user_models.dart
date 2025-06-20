class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? bio;
  final String? profileImagePath;
  final DateTime joinDate;
  final DateTime? lastUpdated;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.bio,
    this.profileImagePath,
    required this.joinDate,
    this.lastUpdated,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? profileImagePath,
    DateTime? joinDate,
    DateTime? lastUpdated,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      joinDate: joinDate ?? this.joinDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'bio': bio,
      'profileImagePath': profileImagePath,
      'joinDate': joinDate.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      bio: json['bio'],
      profileImagePath: json['profileImagePath'],
      joinDate: DateTime.parse(json['joinDate']),
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated']) 
          : null,
    );
  }
}
