import 'package:madinaapp/models/models.dart';

class AuthenticationRepository {
  static const _dummyUsers = [
    User(
      id: '1',
      email: 'client@example.com',
      role: UserRole.client,
      name: 'Client User',
    ),
    User(
      id: '2',
      email: 'owner@example.com',
      role: UserRole.shopOwner,
      name: 'Shop Owner',
    ),
    User(
      id: '3',
      email: 'logistic@example.com',
      role: UserRole.logistic,
      name: 'Logistic User',
    ),
  ];

  /// Signs in with the provided [email] and [password].
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    // Find user by email
    final user = _dummyUsers.where((user) => user.email == email).firstOrNull;

    if (user == null) {
      throw Exception('User not found');
    }

    // For demo purposes, accept any password
    if (password.isEmpty) {
      throw Exception('Password is required');
    }

    return user;
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  /// Get list of dummy users for UI display
  List<User> get dummyUsers => _dummyUsers;
}
