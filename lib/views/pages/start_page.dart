import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_resendis/views/pages/signup_page.dart';
import 'package:project_resendis/views/pages/apppage_page.dart';
import 'package:project_resendis/styles/app_dimensions.dart';
import 'package:project_resendis/styles/app_colors.dart';
import 'package:project_resendis/widgets/loading_indicator.dart';
import 'package:project_resendis/widgets/gradient_background.dart';
import 'package:project_resendis/widgets/animated_logo.dart';
import 'package:project_resendis/widgets/custom_text_field.dart';
import 'package:project_resendis/widgets/custom_button.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _login() async {
    // Validar que los campos no estén vacíos
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, completa todos los campos';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: _usernameController.text.trim())
              .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = 'Usuario no encontrado';
          _isLoading = false;
        });
        return;
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();

      if (userData['password'] == _passwordController.text.trim()) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AppPage()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Contraseña incorrecta';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ha ocurrido un error. Por favor, intenta de nuevo.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GradientBackground(
        colors: isDarkMode
            ? [Colors.grey.shade900, Colors.black]
            : [Colors.teal.shade300, Colors.teal.shade700],
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animado
                  Hero(
                    tag: 'app_logo',
                    child: AnimatedLogo(size: 120),
                  ),
                  const SizedBox(height: 30),

                  // Título y subtítulo con animación
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      'Bienvenido',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      'Inicia sesión para continuar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Tarjeta de inicio de sesión con animación
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutQuart,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey.shade800.withOpacity(0.8)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusLarge,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.teal.withOpacity(0.3)
                              : Colors.teal.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Campo de usuario personalizado
                          CustomTextField(
                            controller: _usernameController,
                            label: 'Usuario',
                            prefixIcon: Icons.person,
                          ),
                          const SizedBox(height: 20),

                          // Campo de contraseña personalizado
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Contraseña',
                            prefixIcon: Icons.lock,
                            obscureText: true,
                          ),

                          // Mensaje de error
                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadiusSmall,
                                  ),
                                  border: Border.all(color: Colors.red.shade300),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage,
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 25),

                          // Botón de inicio de sesión personalizado
                          CustomButton(
                            text: 'Iniciar Sesión',
                            onPressed: _isLoading ? () {} : _login,
                            backgroundColor: isDarkMode
                                ? Colors.teal.shade700
                                : Colors.teal.shade500,
                            icon: Icons.login,
                            height: 50,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Enlace para registrarse con animación
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: child,
                      );
                    },
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                      ),
                      child: const Text(
                        '¿No tienes una cuenta? Regístrate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
