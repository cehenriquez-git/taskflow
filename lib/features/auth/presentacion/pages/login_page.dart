import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validadores_auth.dart';
import '../../../../shared/widgets/auth_error_banner.dart';
import '../../../../shared/widgets/auth_primary_button.dart';
import '../../../../shared/widgets/auth_text_field.dart';
import '../../data/auth_service.dart';
import '../providers/auth_provider.dart';

/// Login (ruta '/login').
/// Estado EFÍMERO (controladores, cargando, error) en el State; el usuario
/// autenticado (estado de la app) se guarda en authProvider.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _cargando = false;
  String? _error; // credenciales inválidas

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (_cargando) return; // protección extra contra doble toque
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await ref.read(authProvider.notifier).iniciarSesion(
            correo: _correoCtrl.text,
            password: _passwordCtrl.text,
          );

      // Safe-await: la pantalla pudo cerrarse durante los 1.5 s de espera.
      if (!mounted) return;

      // Reemplaza TODA la pila: el botón «atrás» ya no vuelve al Login.
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.publicaciones,
        (_) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.mensaje;
        _cargando = false;
      });
    }
  }

  Future<void> _irARegistro() async {
    // Registro devuelve el correo con Navigator.pop(context, correo).
    final correo =
        await Navigator.of(context).pushNamed<String>(AppRoutes.registro);

    // null = el usuario volvió atrás sin registrarse.
    if (correo == null || !mounted) return;

    setState(() {
      _correoCtrl.text = correo; // el correo aparece ya escrito
      _passwordCtrl.clear();
      _error = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cuenta creada. Ya puedes iniciar sesión.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryDark,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.task_alt,
                          size: 40,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Bienvenido',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Inicia sesión para continuar',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 32),
                    AuthTextField(
                      controller: _correoCtrl,
                      label: 'Correo electrónico',
                      icon: Icons.mail_outline,
                      enabled: !_cargando,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: ValidadoresAuth.correo,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _passwordCtrl,
                      label: 'Contraseña',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      enabled: !_cargando,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _iniciarSesion(),
                      validator: ValidadoresAuth.password,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      AuthErrorBanner(mensaje: _error!),
                    ],
                    const SizedBox(height: 24),
                    AuthPrimaryButton(
                      label: 'Iniciar Sesión',
                      isLoading: _cargando,
                      onPressed: _iniciarSesion,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿No tienes cuenta?'),
                        TextButton(
                          onPressed: _cargando ? null : _irARegistro,
                          child: const Text('Regístrate'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Demo: demo@taskflow.com · 12345678',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
