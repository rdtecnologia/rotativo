import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/dynamic_app_config.dart';
import 'config/environment.dart';
import 'providers/auth_provider.dart';

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
                _buildSection('🌐 Ambiente API', [
                  'Ambiente Atual: ${Environment.currentEnvironment}',
                  'Register API: ${Environment.registerApi}',
                  'Autentica API: ${Environment.autenticaApi}',
                  'Transaciona API: ${Environment.transacionaApi}',
                  'Voucher API: ${Environment.voucherApi}',
                ]),
                const SizedBox(height: 16),

                // Environment Switcher
                Card(
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
                                  Environment.setEnvironment('dev');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Ambiente alterado para DEV. Reinicie o app.'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Environment.currentEnvironment == 'dev'
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
                                  Environment.setEnvironment('prod');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Ambiente alterado para PROD. Reinicie o app.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Environment.currentEnvironment == 'prod'
                                          ? Colors.green
                                          : Colors.grey,
                                ),
                                child: const Text('PROD'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
                Text(
                  'Current Environment: ${Environment.currentEnvironment}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
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
}
