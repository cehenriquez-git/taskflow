import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validadores_auth.dart';
import '../../../../shared/widgets/auth_error_banner.dart';
import '../../../../shared/widgets/auth_primary_button.dart';
import '../../../../shared/widgets/auth_text_field.dart';
import '../../data/auth_service.dart';
import '../providers/auth_provider.dart';

/// Registro (ruta '/registro'). Al terminar con éxito hace
/// Navigator.pop(context, correo): quien lo abrió (Login) recibe el correo.
class RegistroPage extends ConsumerStatefulWidget {
  const RegistroPage({super.key});

  @override
  ConsumerState<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends ConsumerState<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // Llave del campo de confirmación: permite validar SOLO ese campo
  // cuando cambia la contraseña.
  final _confirmKey = GlobalKey<FormFieldState<String>>();

  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  /// Si el usuario cambia la contraseña DESPUÉS de escribir la confirmación,
  /// se vuelve a validar la confirmación (y solo esa).
  void _alCambiarPassword(String _) {
    if (_confirmCtrl.text.isNotEmpty) {
      _confirmKey.currentState?.validate();
    }
  }

  Future<void> _registrar() async {
    if (_cargando) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final correo = _correoCtrl.text.trim();
      await ref.read(authProvider.notifier).registrar(
            nombre: _nombreCtrl.text,
            correo: correo,
            password: _passwordCtrl.text,
          );

      if (!mounted) return; // pudo cerrarse durante la espera

      // Devuelve el correo al Login.
      Navigator.of(context).pop(correo);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.mensaje;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryDark,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Crear Cuenta',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Completa tus datos para registrarte',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 24),
                    AuthTextField(
                      controller: _nombreCtrl,
                      label: 'Nombre completo',
                      icon: Icons.person_outline,
                      enabled: !_cargando,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: ValidadoresAuth.nombre,
                    ),
                    const SizedBox(height: 16),
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
                      textInputAction: TextInputAction.next,
                      onChanged: _alCambiarPassword, // re-valida la confirmación
                      validator: ValidadoresAuth.password,
                    ),
                    const SizedBox(height: 16),

                    // ===== VALIDACIÓN CRUZADA =====
                    // El validador lee _passwordCtrl.text EN EL MOMENTO de validar
                    // (no un valor copiado antes), así siempre compara con lo
                    // que hay escrito ahora en el campo de contraseña.
                    AuthTextField(
                      fieldKey: _confirmKey,
                      controller: _confirmCtrl,
                      label: 'Confirmar contraseña',
                      icon: Icons.lock_reset_outlined,
                      isPassword: true,
                      enabled: !_cargando,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _registrar(),
                      validator: (valor) => ValidadoresAuth.confirmacion(
                        valor,
                        _passwordCtrl.text,
                      ),
                    ),

                    const SizedBox(height: 8),
                    FormField<bool>(
                      initialValue: false,
                      validator: (v) => v == true
                          ? null
                          : 'Debes aceptar los términos y condiciones.',
                      builder: (campo) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: AppColors.primaryDark,
                            value: campo.value ?? false,
                            onChanged: _cargando ? null : campo.didChange,
                            title: const Text(
                              'Acepto los términos y condiciones',
                            ),
                          ),
                          if (campo.hasError)
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                campo.errorText!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      AuthErrorBanner(mensaje: _error!),
                    ],
                    const SizedBox(height: 16),
                    AuthPrimaryButton(
                      label: 'Registrarse',
                      isLoading: _cargando,
                      onPressed: _registrar,
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
