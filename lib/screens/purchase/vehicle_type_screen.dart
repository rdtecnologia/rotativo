import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/purchase_provider.dart';
import 'choose_value_screen.dart';

class VehicleTypeScreen extends ConsumerWidget {
  const VehicleTypeScreen({Key? key}) : super(key: key);

  String _getVehicleTypeName(int vehicleType) {
    switch (vehicleType) {
      case 1:
        return 'Carro';
      case 2:
        return 'Moto';
      case 3:
        return 'Caminhão';
      case 4:
        return 'Motocicleta';
      case 5:
        return 'Caminhão Grande';
      default:
        return 'Veículo';
    }
  }

  IconData _getVehicleTypeIcon(int vehicleType) {
    switch (vehicleType) {
      case 1:
        return Icons.directions_car;
      case 2:
      case 4:
        return Icons.motorcycle;
      case 3:
      case 5:
        return Icons.local_shipping;
      default:
        return Icons.directions_car;
    }
  }

  void _selectVehicleType(BuildContext context, WidgetRef ref, int vehicleType) {
    ref.read(purchaseProvider.notifier).selectVehicleType(vehicleType);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChooseValueScreen(vehicleType: vehicleType),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleTypesAsync = ref.watch(vehicleTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprar Créditos'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecione o tipo de crédito que deseja comprar:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            
            Expanded(
              child: vehicleTypesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar tipos de veículos',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(vehicleTypesProvider);
                        },
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
                data: (vehicleTypes) {
                  if (vehicleTypes.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum tipo de veículo disponível',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: vehicleTypes.length,
                    itemBuilder: (context, index) {
                      final vehicleType = vehicleTypes[index];
                      
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _selectVehicleType(context, ref, vehicleType),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getVehicleTypeIcon(vehicleType),
                                  size: 64,
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Crédito para',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getVehicleTypeName(vehicleType),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
