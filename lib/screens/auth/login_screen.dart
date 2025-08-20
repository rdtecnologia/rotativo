import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../config/dynamic_app_config.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/formatters.dart';
import '../../widgets/parking_background.dart';
import '../widgets/loading_button.dart';
import '../widgets/app_text_field.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../services/biometric_service.dart';
import '../../services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _showLoginCard = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();

    // Clear any previous errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).clearError();
    });
  }

  Future<void> _checkBiometricStatus() async {
    try {
      final available = await BiometricService.isBiometricAvailable();
      final enabled = await AuthService.isBiometricEnabled();
      final credentials = await AuthService.getStoredCredentials();

      // Só habilita biometria se tiver credenciais armazenadas E biometria estiver habilitada
      final finalEnabled = available && enabled && credentials != null;

      if (mounted) {
        setState(() {
          _biometricAvailable = available;
          _biometricEnabled = finalEnabled;
          // Se biometria estiver ativa, oculta o card de login por padrão
          _showLoginCard = !finalEnabled;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _biometricAvailable = false;
          _biometricEnabled = false;
        });
      }
    }
  }

  void _toggleLoginCard() {
    setState(() {
      _showLoginCard = !_showLoginCard;
    });
  }

  Future<void> _handleBiometricLogin() async {
    // Primeiro verifica se há credenciais armazenadas
    final credentials = await AuthService.getStoredCredentials();
    if (credentials == null) {
      Fluttertoast.showToast(
        msg:
            'Primeiro faça login tradicional e configure a biometria nas configurações',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
      );
      return;
    }

    try {
      final success =
          await ref.read(authProvider.notifier).loginWithBiometrics();

      if (success) {
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
        final error = ref.read(authProvider).error;
        if (error != null) {
          Fluttertoast.showToast(
            msg: error,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erro ao fazer login biométrico: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
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
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          ParkingBackground(
            primaryColor: Theme.of(context).primaryColor,
            opacity: 0.25,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo and City Name
                      FutureBuilder<String>(
                        future: DynamicAppConfig.cityName,
                        builder: (context, snapshot) {
                          final cityName = snapshot.data ?? 'Rotativo Digital';
                          return Column(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(60),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.local_parking,
                                  size: 60,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Rotativo $cityName',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 48),

                      // Opção biométrica (só se estiver realmente configurada)
                      if (_biometricEnabled) ...[
                        Card(
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
                                LoadingButton(
                                  onPressed: () {
                                    _handleBiometricLogin();
                                  },
                                  isLoading: false,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.fingerprint, size: 20),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Usar Biometria',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white54)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'ou',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white54)),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Botão para mostrar/ocultar login tradicional quando biometria estiver ativa
                      if (_biometricEnabled && !_showLoginCard) ...[
                        TextButton.icon(
                          onPressed: _toggleLoginCard,
                          icon: const Icon(Icons.login, color: Colors.white54),
                          label: const Text(
                            'Usar login tradicional',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Login Form (condicional)
                      if (_showLoginCard) ...[
                        Card(
                          elevation: 0,
                          color: Colors.grey.withValues(alpha: 0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: FormBuilder(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Faça login na sua conta',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    'Digite suas credenciais para acessar',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 32),

                                  // CPF Field
                                  AppTextField(
                                    name: 'cpf',
                                    label: 'CPF',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      AppFormatters.cpfFormatter
                                    ],
                                    validator: AppValidators.validateCPF,
                                    prefixIcon: const Icon(Icons.person),
                                    fillColor: Colors.white.withAlpha(100),
                                  ),

                                  const SizedBox(height: 16),

                                  // Password Field
                                  AppTextField(
                                    name: 'password',
                                    label: 'Senha',
                                    obscureText: true,
                                    validator: AppValidators.validatePassword,
                                    prefixIcon: const Icon(Icons.lock),
                                    fillColor: Colors.white.withAlpha(100),
                                  ),

                                  const SizedBox(height: 24),

                                  // Login Button
                                  LoadingButton(
                                    onPressed: _handleLogin,
                                    isLoading: authState.isLoading,
                                    child: const Text(
                                      'Entrar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Register Link
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        children: [
                                          const TextSpan(
                                            text: 'Não tem uma conta? ',
                                            style: TextStyle(
                                                color: Colors.white60),
                                          ),
                                          TextSpan(
                                            text: 'Cadastre-se',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
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
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Forgot Password Link
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Esqueceu sua senha?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        // Botão para ocultar login quando biometria estiver ativa
                        if (_biometricEnabled) ...[
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: _toggleLoginCard,
                            icon: const Icon(Icons.fingerprint,
                                color: Colors.white54),
                            label: const Text(
                              'Usar apenas biometria',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
