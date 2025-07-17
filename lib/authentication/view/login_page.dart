import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:madinaapp/authentication/bloc/bloc.dart';
import 'package:madinaapp/models/models.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            // Navigation will be handled by GoRouter
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: const Color(0xFFED3241),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top section with image
                  // Login form section
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Role switcher
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              _buildRoleTab(UserRole.client, 'Клиент'),
                              _buildRoleTab(UserRole.shopOwner, 'Бизнес'),
                              _buildRoleTab(UserRole.logistic, 'Логистика'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Welcome text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Добро пожаловать!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF1F2024),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Мадина - первый цифровой!',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F2024),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Email field
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Адрес электронной почты',
                          prefillText: _getEmailForRole(),
                        ),
                        const SizedBox(height: 16),
                        // Password field
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'Пароль',
                          isPassword: true,
                          prefillText: 'password',
                        ),
                        const SizedBox(height: 12),
                        // Forgot password
                        const Text(
                          'Забыли пароль?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF006FFD),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed:
                                state.status == AuthenticationStatus.loading
                                    ? null
                                    : _onLoginPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006FFD),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: state.status == AuthenticationStatus.loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Войти',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Register text
                        const Center(
                          child: Text(
                            'Не участник? зарегистрироваться сейчас',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF71727A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Divider
                        const Divider(color: Color(0xFFC5C6CC)),
                        const SizedBox(height: 24),
                        // Social login
                        const Center(
                          child: Text(
                            'Или продолжить с',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF71727A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Social buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialButton(
                              color: const Color(0xFFED3241),
                              icon: Icons.g_mobiledata,
                            ),
                            const SizedBox(width: 12),
                            _buildSocialButton(
                              color: const Color(0xFF25D366),
                              icon: FontAwesomeIcons.whatsapp,
                            ),
                            const SizedBox(width: 12),
                            _buildSocialButton(
                              color: const Color(0xFFE4405F),
                              icon: FontAwesomeIcons.instagram,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleTab(UserRole role, String title) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
            _emailController.text = _getEmailForRole();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? const Color(0xFF1F2024)
                  : const Color(0xFF71727A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    String? prefillText,
  }) {
    // Auto-fill the field when role changes
    if (prefillText != null && controller.text.isEmpty) {
      controller.text = prefillText;
    }

    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC5C6CC)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF1F2024),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8F9098),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? const Icon(
                  Icons.visibility_off,
                  color: Color(0xFF8F9098),
                  size: 16,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: icon == Icons.g_mobiledata
            ? 20
            : 16, // Smaller size for FontAwesome icons
      ),
    );
  }

  String _getEmailForRole() {
    switch (_selectedRole) {
      case UserRole.client:
        return 'client@example.com';
      case UserRole.shopOwner:
        return 'owner@example.com';
      case UserRole.logistic:
        return 'logistic@example.com';
    }
  }

  void _onLoginPressed() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, заполните все поля'),
          backgroundColor: Color(0xFFED3241),
        ),
      );
      return;
    }

    context.read<AuthenticationBloc>().add(
          AuthenticationSignInRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
  }
}
