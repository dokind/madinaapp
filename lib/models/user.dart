import 'package:equatable/equatable.dart';

enum UserRole {
  client,
  shopOwner,
  logistic,
}

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
  });

  final String id;
  final String email;
  final UserRole role;
  final String name;

  @override
  List<Object> get props => [id, email, role, name];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.name,
      'name': name,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => UserRole.client,
      ),
      name: json['name'] as String,
    );
  }
}
