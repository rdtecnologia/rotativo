import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/dynamic_app_config.dart';
import 'config/environment.dart';
import 'providers/auth_provider.dart';
import 'providers/environment_provider.dart';
import 'services/firebase_service.dart';
import 'utils/firebase_analytics_helper.dart';

class DebugPage extends ConsumerWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug - Configurações'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: DynamicAppConfig.getDebugInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text('Erro: ${snapshot.error}'),
                ],
              ),
            );
          }

          final debugInfo = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('🌍 Variáveis de Ambiente', [
                  'FLAVOR: ${debugInfo['flavor']}',
                  'CITY_NAME: ${debugInfo['cityName']}',
                  'Configurado: ${debugInfo['isConfigured']}',
                  'Info: ${debugInfo['displayInfo']}',
                ]),
                const SizedBox(height: 16),
                _buildSection('📁 Mapeamento', [
                  'Flavor: ${debugInfo['flavor']}',
                  'Diretório: ${debugInfo['configuredCityDirectory']}',
                ]),
                const SizedBox(height: 16),
                FutureBuilder<Map<String, dynamic>>(
                  future: _loadConfigInfo(),
                  builder: (context, configSnapshot) {
                    if (configSnapshot.hasData) {
                      final configInfo = configSnapshot.data!;
                      return _buildSection('⚙️ Configuração Carregada', [
                        'Cidade Config: ${configInfo['cityName']}',
                        'Domínio: ${configInfo['domain']}',
                        'Latitude: ${configInfo['latitude']}',
                        'Longitude: ${configInfo['longitude']}',
                        'Android Package: ${configInfo['androidPackage']}',
                        'iOS Package: ${configInfo['iosPackage']}',
                        'Produtos: ${configInfo['products']}',
                        'Tipos de Veículo: ${configInfo['vehicleTypes']}',
                      ]);
                    }
                    return const CircularProgressIndicator();
                  },
                ),
                const SizedBox(height: 16),

                // API Environment Debug Info
                Consumer(
                  builder: (context, ref, child) {
                    final envState = ref.watch(environmentProvider);
                    return _buildSection('🌐 Ambiente API', [
                      'Ambiente Atual: ${envState.currentEnvironment}',
                      'Register API: ${Environment.registerApi}',
                      'Autentica API: ${Environment.autenticaApi}',
                      'Transaciona API: ${Environment.transacionaApi}',
                      'Voucher API: ${Environment.voucherApi}',
                    ]);
                  },
                ),
                const SizedBox(height: 16),

                // Environment Switcher
                Consumer(
                  builder: (context, ref, child) {
                    final envState = ref.watch(environmentProvider);
                    final envNotifier = ref.read(environmentProvider.notifier);

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🔧 Trocar Ambiente',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      envNotifier.setEnvironment('dev');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Ambiente alterado para DEV. Reinicie o app.'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          envState.currentEnvironment == 'dev'
                                              ? Colors.orange
                                              : Colors.grey,
                                    ),
                                    child: const Text('DEV'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      envNotifier.setEnvironment('prod');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Ambiente alterado para PROD. Reinicie o app.'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          envState.currentEnvironment == 'prod'
                                              ? Colors.green
                                              : Colors.grey,
                                    ),
                                    child: const Text('PROD'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      envNotifier.setEnvironment('offline');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Ambiente alterado para OFFLINE. Reinicie o app.'),
                                          backgroundColor: Colors.grey,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          envState.currentEnvironment ==
                                                  'offline'
                                              ? Colors.grey
                                              : Colors.grey.shade400,
                                    ),
                                    child: const Text('OFFLINE'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Firebase Debug Info
                _buildFirebaseSection(),
                const SizedBox(height: 16),

                // Auth Debug Info
                Consumer(
                  builder: (context, ref, child) {
                    final authState = ref.watch(authProvider);
                    final user = authState.user;

                    return _buildSection('🔐 Debug Autenticação', [
                      'Autenticado: ${authState.isAuthenticated}',
                      'Carregando: ${authState.isLoading}',
                      'Erro: ${authState.error ?? 'Nenhum'}',
                      if (user != null) ...[
                        'User ID: ${user.id ?? 'N/A'}',
                        'Nome: ${user.name ?? 'N/A'}',
                        'Email: ${user.email ?? 'N/A'}',
                        'CPF: ${user.cpf ?? 'N/A'}',
                        'Telefone: ${user.phone ?? 'N/A'}',
                        'Tem Token: ${user.token != null}',
                        if (user.token != null)
                          'Token: ${user.token!.substring(0, 20)}...',
                      ] else
                        'Dados do usuário: Não disponível',
                    ]);
                  },
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, child) {
                    final envState = ref.watch(environmentProvider);
                    return Text(
                      'Current Environment: ${envState.currentEnvironment}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    item,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _loadConfigInfo() async {
    return {
      'cityName': await DynamicAppConfig.cityName,
      'domain': await DynamicAppConfig.domain,
      'latitude': await DynamicAppConfig.latitude,
      'longitude': await DynamicAppConfig.longitude,
      'androidPackage': await DynamicAppConfig.androidPackage,
      'iosPackage': await DynamicAppConfig.iosPackage,
      'products': await DynamicAppConfig.products,
      'vehicleTypes': await DynamicAppConfig.vehicleTypes,
    };
  }

  Widget _buildFirebaseSection() {
    final firebaseService = FirebaseService.instance;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔥 Firebase Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Firebase Status Info
            _buildFirebaseStatus(firebaseService),
            const SizedBox(height: 16),

            // Firebase Test Buttons
            _buildFirebaseTestButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFirebaseStatus(FirebaseService firebaseService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              firebaseService.analytics != null
                  ? Icons.check_circle
                  : Icons.error,
              color:
                  firebaseService.analytics != null ? Colors.green : Colors.red,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
                'Analytics: ${firebaseService.analytics != null ? "Ativo" : "Inativo"}'),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              firebaseService.crashlytics != null
                  ? Icons.check_circle
                  : Icons.error,
              color: firebaseService.crashlytics != null
                  ? Colors.green
                  : Colors.red,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
                'Crashlytics: ${firebaseService.crashlytics != null ? "Ativo" : "Inativo"}'),
          ],
        ),
        const SizedBox(height: 4),
        Text('Flavor: ${Environment.flavor}'),
        Text('Inicializado: ${firebaseService.isInitialized}'),
      ],
    );
  }

  Widget _buildFirebaseTestButtons() {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '🧪 Testes Firebase',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Analytics Test Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAnalyticsHelper.logCustomEvent(
                      'debug_test_event',
                      parameters: {
                        'test_type': 'analytics',
                        'timestamp': DateTime.now().millisecondsSinceEpoch,
                        'flavor': Environment.flavor,
                      },
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Evento de Analytics enviado!')),
                    );
                  },
                  icon: const Icon(Icons.analytics, size: 16),
                  label: const Text('Test Analytics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAnalyticsHelper.logScreenView(
                        'debug_test_screen');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Screen View Analytics enviado!')),
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Test Screen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Crashlytics Test Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseCrashlyticsHelper.logError(
                      Exception('Teste de erro não-fatal do Debug'),
                      StackTrace.current,
                      reason: 'Teste manual de Crashlytics - Debug Page',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Erro não-fatal enviado para Crashlytics!')),
                    );
                  },
                  icon: const Icon(Icons.warning, size: 16),
                  label: const Text('Test Error'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseCrashlyticsHelper.log(
                        'Teste de log do Crashlytics - Debug Page');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Log enviado para Crashlytics!')),
                    );
                  },
                  icon: const Icon(Icons.description, size: 16),
                  label: const Text('Test Log'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // API Error Test
          ElevatedButton.icon(
            onPressed: () async {
              await FirebaseCrashlyticsHelper.recordApiError(
                endpoint: '/api/debug/test',
                statusCode: 500,
                method: 'GET',
                errorMessage: 'Teste de erro de API do Debug Page',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Erro de API enviado para Crashlytics!')),
              );
            },
            icon: const Icon(Icons.api, size: 16),
            label: const Text('Test API Error'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // User Properties Test
          ElevatedButton.icon(
            onPressed: () async {
              await FirebaseAnalyticsHelper.setUserProperties(
                userId: 'debug_user_${DateTime.now().millisecondsSinceEpoch}',
                userType: 'debug',
                city: Environment.flavor,
                vehicleType: 'test',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Propriedades do usuário definidas!')),
              );
            },
            icon: const Icon(Icons.person, size: 16),
            label: const Text('Set User Properties'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Force Send Reports
          ElevatedButton.icon(
            onPressed: () async {
              final firebaseService = FirebaseService.instance;
              final hasUnsent = await firebaseService.checkForUnsentReports();

              if (hasUnsent) {
                await firebaseService.sendUnsentReports();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📤 Relatórios não enviados foram enviados!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Não há relatórios pendentes'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            icon: const Icon(Icons.upload, size: 16),
            label: const Text('Force Send Reports'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
