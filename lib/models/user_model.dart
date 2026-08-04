class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final bool isPremium;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.isPremium = false,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    bool? isPremium,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
