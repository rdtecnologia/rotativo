import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/biometric_settings_provider.dart';

class BiometricSettingsScreen extends ConsumerStatefulWidget {
  const BiometricSettingsScreen({super.key});

  @override
  ConsumerState<BiometricSettingsScreen> createState() =>
      _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState
    extends ConsumerState<BiometricSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Sincronizar o status biométrico quando a tela for carregada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).syncBiometricStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            const _BiometricHeader(),
            const SizedBox(height: 16),
            // Status da biometria
            const _BiometricStatusCard(),
            const SizedBox(height: 20),
            // Configuração da biometria
            const _BiometricConfigurationCard(),
            const SizedBox(height: 20),
            // Informações adicionais
            const _BiometricInfoCard(),
          ],
        ),
      ),
    );
  }
}

class _BiometricHeader extends StatelessWidget {
  const _BiometricHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _BiometricStatusCard extends ConsumerWidget {
  const _BiometricStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricState = ref.watch(biometricSettingsProvider);

    return Card(
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
                  biometricState.biometricAvailable
                      ? Icons.fingerprint
                      : Icons.fingerprint_outlined,
                  color: biometricState.biometricAvailable
                      ? Colors.green
                      : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Impressão Digital',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        biometricState.biometricAvailable
                            ? 'Disponível neste dispositivo'
                            : 'Não disponível neste dispositivo',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BiometricConfigurationCard extends ConsumerWidget {
  const _BiometricConfigurationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricState = ref.watch(biometricSettingsProvider);
    final authState = ref.watch(authProvider);

    if (!biometricState.biometricAvailable) {
      return const SizedBox.shrink();
    }

    return Card(
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
                Text(
                  'Configuração',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    ref
                        .read(biometricSettingsProvider.notifier)
                        .refreshBiometricStatus();
                    ref.read(authProvider.notifier).syncBiometricStatus();
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Atualizar status',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status das credenciais
            Row(
              children: [
                Icon(
                  biometricState.hasStoredCredentials
                      ? Icons.check_circle
                      : Icons.warning,
                  color: biometricState.hasStoredCredentials
                      ? Colors.green
                      : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    biometricState.hasStoredCredentials
                        ? 'Credenciais biométricas disponíveis'
                        : 'Credenciais biométricas não encontradas',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status da biometria
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Botões de ação
            if (biometricState.hasStoredCredentials) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        authState.biometricEnabled ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: authState.biometricEnabled
                      ? () => _disableBiometric(context, ref)
                      : () => _enableBiometric(context, ref),
                  child: Text(
                    authState.biometricEnabled
                        ? 'Desabilitar Biometria'
                        : 'Habilitar Biometria',
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'Para habilitar a biometria, você precisa fazer login primeiro',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Fazer Login'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _enableBiometric(BuildContext context, WidgetRef ref) async {
    try {
      final success =
          await ref.read(authProvider.notifier).enableBiometricAuth();

      if (success && context.mounted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Autenticação biométrica habilitada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Erro ao habilitar biometria. Faça login primeiro.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disableBiometric(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desabilitar Biometria'),
        content: const Text(
            'Tem certeza que deseja desabilitar a autenticação biométrica?\n\n'
            'Você poderá reabilitar a biometria a qualquer momento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success =
          await ref.read(authProvider.notifier).disableBiometricAuth();

      if (success && context.mounted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Autenticação biométrica desabilitada (credenciais mantidas)'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }
}

class _BiometricInfoCard extends StatelessWidget {
  const _BiometricInfoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
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
              '• Habilite o login biométrico para acessar o app sem precisar de senha\n'
              '• Suas digitais poderão ser usadas para acessar o app facilitando o login\n'
              '• Você poderá desabilitar a biometria a qualquer momento',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
