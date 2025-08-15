import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/vehicle_models.dart';
import '../../providers/parking_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/balance_provider.dart';
import '../../config/dynamic_app_config.dart';
import '../../utils/formatters.dart';
import 'widgets/parking_time_card.dart';
import 'widgets/parking_map.dart';

class ParkingScreen extends ConsumerStatefulWidget {
  final Vehicle vehicle;

  const ParkingScreen({
    Key? key,
    required this.vehicle,
  }) : super(key: key);

  @override
  ConsumerState<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends ConsumerState<ParkingScreen> {
  Position? _currentPosition;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada permanentemente');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isGettingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao obter localização: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatLicensePlate(String plate) {
    return AppFormatters.formatPlate(plate);
  }

  String _formatParkingTime(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}min';
      }
    }
  }

  Future<void> _submitParking() async {
    final selectedTime = ref.read(selectedParkingTimeProvider);
    final selectedCredits = ref.read(selectedCreditsProvider);

    if (selectedTime == null || selectedCredits == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o tempo de estacionamento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aguarde a obtenção da localização atual'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Check current balance first
      final currentBalance = ref.read(currentBalanceProvider);
      if (currentBalance == null || currentBalance.credits < selectedCredits) {
        final requiredCredits = selectedCredits;
        final availableCredits = currentBalance?.credits ?? 0;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Créditos insuficientes!\n'
              'Você possui: ${availableCredits.toStringAsFixed(1)} créditos\n'
              'Necessário: ${requiredCredits.toStringAsFixed(1)} créditos\n'
              'Faça uma compra de créditos para continuar.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }

      // First, get possible parking tickets
      final possibleParking = await ref.read(parkingProvider.notifier).getPossibleParking(
        licensePlate: widget.vehicle.licensePlate,
        quantity: selectedCredits.toString(),
      );

      // Check if there are sufficient tickets
      if (possibleParking.tickets.isEmpty ||
          possibleParking.tickets[0].tickets.isEmpty ||
          possibleParking.tickets[0].tickets.length < selectedCredits) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Créditos insuficientes para estacionar!\n'
              'Você possui: ${currentBalance?.credits.toStringAsFixed(1) ?? '0'} créditos\n'
              'Necessário: ${selectedCredits.toStringAsFixed(1)} créditos\n'
              'Faça uma compra de créditos para continuar.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmação'),
          content: Text(
            possibleParking.message ??
            'Tem certeza que deseja realizar esta ativação de seus créditos para placa ${_formatLicensePlate(widget.vehicle.licensePlate)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Activate parking
      final parkingResponse = await ref.read(parkingProvider.notifier).activateParking(
        licensePlate: widget.vehicle.licensePlate,
        ticketIds: possibleParking.tickets[0].tickets,
      );

      // Reload vehicles and balance
      await Future.wait([
        ref.read(vehicleProvider.notifier).loadVehicles(),
        ref.read(balanceProvider.notifier).loadBalance(),
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Estacionamento ativado com sucesso!\nID: ${parkingResponse.id}',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Return to home
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

    } catch (e) {
      if (mounted) {
        String errorMessage = 'Erro ao ativar estacionamento';
        
        // Extract error message from exception
        if (e.toString().contains('Fora do horário de funcionamento')) {
          errorMessage = '❌ Fora do horário de funcionamento\n'
              'O estacionamento não está disponível neste horário.';
        } else if (e.toString().contains('Créditos insuficientes')) {
          errorMessage = '❌ Créditos insuficientes\n'
              'Você não possui créditos suficientes para esta operação.';
        } else if (e.toString().contains('Erro de conexão')) {
          errorMessage = '❌ Erro de conexão\n'
              'Verifique sua conexão com a internet e tente novamente.';
        } else {
          errorMessage = '❌ Erro ao ativar estacionamento\n'
              '${e.toString().replaceAll('Exception: ', '')}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTime = ref.watch(selectedParkingTimeProvider);
    final isLoading = ref.watch(parkingLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatLicensePlate(widget.vehicle.licensePlate)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Map section
          Expanded(
            flex: 2,
            child: ParkingMap(
              currentPosition: _currentPosition,
              isGettingLocation: _isGettingLocation,
              onRetryLocation: _getCurrentLocation,
            ),
          ),
          
          // Parking options section
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Escolha o tempo de estacionamento:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Parking time options
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        // Refresh parking rules and reload data
                        setState(() {});
                      },
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: DynamicAppConfig.parkingRules,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Erro ao carregar opções: ${snapshot.error}'),
                            );
                          }

                          final parkingRules = snapshot.data ?? {};
                          final vehicleRules = parkingRules[widget.vehicle.type.toString()] as List<dynamic>? ?? [];

                          if (vehicleRules.isEmpty) {
                            return const Center(
                              child: Text('Nenhuma opção de estacionamento disponível para este veículo'),
                            );
                          }

                          return ListView.builder(
                            itemCount: vehicleRules.length,
                            itemBuilder: (context, index) {
                              final rule = vehicleRules[index] as Map<String, dynamic>;
                              final time = rule['time'] as int? ?? 0;
                              final credits = rule['credits'] as int? ?? 0;
                              final price = (rule['price'] as num?)?.toDouble() ?? 0.0;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    final currentBalance = ref.watch(currentBalanceProvider);
                                    return ParkingTimeCard(
                                      time: time,
                                      credits: credits,
                                      price: price,
                                      isSelected: selectedTime == time,
                                      availableCredits: currentBalance?.credits,
                                      onTap: () {
                                        ref.read(parkingProvider.notifier).selectParkingTime(time, credits);
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Warning message
                  if (selectedTime != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'ATENÇÃO: Ao estacionar verifique nas placas de sinalização o tempo máximo permitido para estacionamento nesta vaga. Próximo ao término do tempo válido de estacionamento informado, você receberá um ALERTA!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Parking button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitParking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              selectedTime != null
                                  ? 'ESTACIONAR: ${_formatParkingTime(selectedTime)}'
                                  : 'ESTACIONAR',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
