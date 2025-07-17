import 'package:bloc/bloc.dart';
import 'package:madinaapp/authentication/bloc/authentication_event.dart';
import 'package:madinaapp/authentication/bloc/authentication_state.dart';
import 'package:madinaapp/repositories/repositories.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const AuthenticationState()) {
    on<AuthenticationSignInRequested>(_onSignInRequested);
    on<AuthenticationSignOutRequested>(_onSignOutRequested);
    on<AuthenticationStatusChanged>(_onStatusChanged);
  }

  final AuthenticationRepository _authenticationRepository;

  Future<void> _onSignInRequested(
    AuthenticationSignInRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.loading));

    try {
      final user = await _authenticationRepository.signIn(
        email: event.email,
        password: event.password,
      );

      emit(state.copyWith(
        status: AuthenticationStatus.authenticated,
        user: user,
        error: null,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: AuthenticationStatus.unauthenticated,
        error: error.toString(),
      ));
    }
  }

  Future<void> _onSignOutRequested(
    AuthenticationSignOutRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.loading));

    try {
      await _authenticationRepository.signOut();
      emit(state.copyWith(
        status: AuthenticationStatus.unauthenticated,
        user: null,
        error: null,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: error.toString(),
      ));
    }
  }

  Future<void> _onStatusChanged(
    AuthenticationStatusChanged event,
    Emitter<AuthenticationState> emit,
  ) async {
    // This event can be used to refresh authentication status
    // For now, we'll just emit the current state
    emit(state);
  }
}
