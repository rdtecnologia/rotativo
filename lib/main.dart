import 'package:flutter/material.dart';
import 'config/dynamic_app_config.dart';
import 'debug_page.dart';

void main() {
  runApp(const RotativoApp());
}

class RotativoApp extends StatelessWidget {
  const RotativoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: DynamicAppConfig.displayName,
      builder: (context, snapshot) {
        final title = snapshot.data ?? 'Rotativo Digital';
        return MaterialApp(
          title: title,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadAllData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Erro'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar configurações: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Force rebuild
                      DynamicAppConfig.clearCache();
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(data['displayName']),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DebugPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.bug_report),
                tooltip: 'Debug',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cidade: ${data['cityName']}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text('Domínio: ${data['domain']}'),
                        Text('Latitude: ${data['latitude']}'),
                        Text('Longitude: ${data['longitude']}'),
                        Text('Package Android: ${data['androidPackage']}'),
                        Text('Package iOS: ${data['iosPackage']}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Produtos Disponíveis',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ...(data['products'] as List<int>).map((productId) => 
                          Text('• Produto ID: $productId')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipos de Veículo',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ...(data['vehicleTypes'] as List<int>).map((typeId) => 
                          Text('• Tipo ID: $typeId')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FAQ (${(data['faq'] as List).length} itens)',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: (data['faq'] as List).length,
                              itemBuilder: (context, index) {
                                final faqItem = (data['faq'] as List)[index];
                                return ExpansionTile(
                                  title: Text(faqItem['title']),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(faqItem['content']),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadAllData() async {
    return {
      'cityName': await DynamicAppConfig.cityName,
      'displayName': await DynamicAppConfig.displayName,
      'domain': await DynamicAppConfig.domain,
      'latitude': await DynamicAppConfig.latitude,
      'longitude': await DynamicAppConfig.longitude,
      'androidPackage': await DynamicAppConfig.androidPackage,
      'iosPackage': await DynamicAppConfig.iosPackage,
      'products': await DynamicAppConfig.products,
      'vehicleTypes': await DynamicAppConfig.vehicleTypes,
      'faq': await DynamicAppConfig.faq,
    };
  }
}
