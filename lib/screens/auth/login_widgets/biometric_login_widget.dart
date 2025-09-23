import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../../widgets/loading_button.dart';

class BiometricLoginWidget extends ConsumerStatefulWidget {
  const BiometricLoginWidget({super.key});

  @override
  ConsumerState<BiometricLoginWidget> createState() =>
      _BiometricLoginWidgetState();
}

class _BiometricLoginWidgetState extends ConsumerState<BiometricLoginWidget> {
  bool _isLoading = false;

  Future<void> _handleBiometricLogin() async {
    // Evitar múltiplas execuções simultâneas
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Adicionar feedback tátil
    HapticFeedback.lightImpact();

    try {
      // ✅ CORREÇÃO: Verificar se o widget ainda está montado antes de operações assíncronas
      if (!mounted) return;

      // Primeiro verifica se há credenciais armazenadas
      final credentials = await AuthService.getStoredCredentials();
      if (!mounted) return; // ✅ Verificar novamente após operação assíncrona

      if (credentials == null) {
        if (!mounted) return;
        Fluttertoast.showToast(
          msg:
              'Primeiro faça login tradicional e configure a biometria nas configurações',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
        );
        return;
      }

      // ✅ CORREÇÃO: Verificar se o widget ainda está montado antes de usar ref
      if (!mounted) return;
      final success =
          await ref.read(authProvider.notifier).loginWithBiometrics();

      // ✅ CORREÇÃO: Verificar se o widget ainda está montado após operação assíncrona
      if (!mounted) return;

      if (success) {
        // Feedback de sucesso
        HapticFeedback.mediumImpact();

        Fluttertoast.showToast(
          msg: 'Login realizado com sucesso!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        // Navigate to main app after successful biometric login
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        // Feedback de erro
        HapticFeedback.heavyImpact();

        // ✅ CORREÇÃO: Verificar se o widget ainda está montado antes de usar ref
        if (!mounted) return;
        final error = ref.read(authProvider).error;

        if (error != null && mounted) {
          Fluttertoast.showToast(
            msg: error,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
          );
        }
      }
    } catch (e) {
      // Feedback de erro
      HapticFeedback.heavyImpact();

      // ✅ CORREÇÃO: Verificar se o widget ainda está montado antes de mostrar toast
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Erro ao fazer login biométrico: $e',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } finally {
      // ✅ CORREÇÃO: Sempre definir loading como false, mas apenas se ainda estiver montado
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.fingerprint,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Entrar com Biometria',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toque no botão para acessar com sua biometria',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            // Usar GestureDetector para melhor controle de eventos
            GestureDetector(
              onTap: _handleBiometricLogin,
              child: LoadingButton(
                onPressed: _handleBiometricLogin,
                isLoading: _isLoading,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fingerprint, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Usar Biometria',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
