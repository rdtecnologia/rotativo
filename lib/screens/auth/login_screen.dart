import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/auth_provider.dart';
import '../../providers/login_screen_provider.dart';
import '../../providers/remember_cpf_provider.dart';
import '../../widgets/parking_background.dart';
import 'login_widgets/login_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Inicializar imediatamente para evitar delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLoginScreen();
    });
  }

  Future<void> _initializeLoginScreen() async {
    if (_isInitialized) return;

    try {
      // Clear any previous errors and initialize login screen state
      ref.read(authProvider.notifier).clearError();
      await ref.read(loginScreenProvider.notifier).initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Erro ao inicializar: $e',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final formData = _formKey.currentState!.value;
    final cpf = formData['cpf'] as String;
    final password = formData['password'] as String;

    try {
      // Direct login attempt
      await ref.read(authProvider.notifier).login(cpf, password);

      // Salvar o CPF se o checkbox "Lembrar meu CPF" estiver marcado
      final rememberCpfState = ref.read(rememberCpfProvider);
      if (rememberCpfState.rememberCpf) {
        await ref.read(rememberCpfProvider.notifier).saveCpf(cpf);
      }

      // Navigate to main app after successful login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Adicionar tratamento de erro para eventos de ponteiro
    return GestureDetector(
      onTap: () {
        // Fechar teclado ao tocar fora dos campos
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        // Fundo branco
        backgroundColor: Colors.white,
        body: ParkingBackground(
          // Usar cor neutra para manter a imagem monocromática
          primaryColor: Colors.white,
          secondaryColor: Colors.white,
          opacity: 0.3, // Opacidade reduzida para não interferir nos textos
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isInitialized) ...[
                      const AppLogoWidget(),
                      const SizedBox(height: 30),
                      const BiometricSectionWidget(),
                      LoginFormSectionWidget(
                        formKey: _formKey,
                        onLogin: _handleLogin,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Limpar recursos ao sair da tela
    super.dispose();
  }
}
