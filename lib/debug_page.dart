import 'package:flutter/material.dart';
import 'config/environment.dart';
import 'config/dynamic_app_config.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
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