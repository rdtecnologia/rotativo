import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';

class BiometricSettingsScreen extends ConsumerStatefulWidget {
  const BiometricSettingsScreen({super.key});

  @override
  ConsumerState<BiometricSettingsScreen> createState() =>
      _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState
    extends ConsumerState<BiometricSettingsScreen> {
  bool _biometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
    _syncBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    print('🔍 BiometricSettingsScreen: Verificando status biométrico...');
    try {
      final available = await BiometricService.isBiometricAvailable();
      final enabled = await AuthService.isBiometricEnabled();
      final biometrics = await BiometricService.getAvailableBiometrics();

      print('🔍 BiometricSettingsScreen: Biometria disponível: $available');
      print('🔍 BiometricSettingsScreen: Biometria habilitada: $enabled');
      print('🔍 BiometricSettingsScreen: Biometrias disponíveis: $biometrics');

      if (mounted) {
        setState(() {
          _biometricAvailable = available;
          _availableBiometrics = biometrics;
        });
      }
    } catch (e) {
      print('❌ BiometricSettingsScreen: Erro ao verificar status: $e');
      if (mounted) {
        setState(() {
          // _isLoading = false; // Removed as per edit hint
        });
      }
    }
  }

  Future<void> _syncBiometricStatus() async {
    print('🔍 BiometricSettingsScreen: Sincronizando estado biométrico...');
    try {
      await ref.read(authProvider.notifier).syncBiometricStatus();
    } catch (e) {
      print('❌ BiometricSettingsScreen: Erro ao sincronizar estado: $e');
    }
  }

  Future<void> _enableBiometric() async {
    try {
      final success =
          await ref.read(authProvider.notifier).enableBiometricAuth();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autenticação biométrica habilitada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao habilitar biometria. Faça login primeiro.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disableBiometric() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desabilitar Biometria'),
        content: const Text(
            'Tem certeza que deseja desabilitar a autenticação biométrica?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success =
          await ref.read(authProvider.notifier).disableBiometricAuth();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autenticação biométrica desabilitada'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações Biométricas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.fingerprint,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Configurações Biométricas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure a autenticação biométrica do app',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Status da biometria
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _biometricAvailable
                              ? Icons.fingerprint
                              : Icons.fingerprint_outlined,
                          color:
                              _biometricAvailable ? Colors.green : Colors.red,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Impressão Digital',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                _biometricAvailable
                                    ? 'Disponível neste dispositivo'
                                    : 'Não disponível neste dispositivo',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_biometricAvailable) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Tipos disponíveis:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ..._availableBiometrics.map((type) => Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  type == BiometricType.fingerprint
                                      ? Icons.fingerprint
                                      : Icons.face,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  type == BiometricType.fingerprint
                                      ? 'Impressão Digital'
                                      : type.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.black87,
                                      ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Configuração da biometria
            if (_biometricAvailable) ...[
              Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configuração',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            authState.biometricEnabled
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: authState.biometricEnabled
                                ? Colors.green
                                : Colors.grey.shade600,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              authState.biometricEnabled
                                  ? 'Login biométrico habilitado'
                                  : 'Login biométrico desabilitado',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.black87,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: authState.biometricEnabled
                                ? Colors.red
                                : Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: authState.biometricEnabled
                              ? _disableBiometric
                              : _enableBiometric,
                          child: Text(
                            authState.biometricEnabled
                                ? 'Desabilitar Biometria'
                                : 'Habilitar Biometria',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Informações adicionais
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Como funciona',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• A impressão digital é usada apenas para autenticação local\n'
                      '• Suas credenciais são armazenadas de forma segura\n'
                      '• O login biométrico não substitui a senha, apenas facilita o acesso\n'
                      '• Você pode desabilitar a qualquer momento',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                            height: 1.5,
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
