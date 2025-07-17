import 'package:equatable/equatable.dart';
import 'package:madinaapp/models/models.dart';

enum AuthenticationStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

class AuthenticationState extends Equatable {
  const AuthenticationState({
    this.status = AuthenticationStatus.initial,
    this.user,
    this.error,
  });

  final AuthenticationStatus status;
  final User? user;
  final String? error;

  AuthenticationState copyWith({
    AuthenticationStatus? status,
    User? user,
    String? error,
  }) {
    return AuthenticationState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, user, error];
}
