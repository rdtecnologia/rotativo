import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/vehicle_models.dart';
import '../../providers/parking_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/balance_provider.dart';
import '../../providers/location_provider.dart';
import '../../config/dynamic_app_config.dart';
import '../../utils/formatters.dart';
import 'widgets/parking_time_card.dart';
import 'widgets/parking_map.dart';

class ParkingScreen extends ConsumerStatefulWidget {
  final Vehicle vehicle;

  const ParkingScreen({
    super.key,
    required this.vehicle,
  });

  @override
  ConsumerState<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends ConsumerState<ParkingScreen> {
  @override
  void initState() {
    super.initState();

    // Always clear any previous selection when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(parkingProvider.notifier).forceClear();
        // Iniciar obtenção de localização após o primeiro frame
        _getCurrentLocation();
        if (kDebugMode) {
          print(
              '🔄 ParkingScreen.initState - Force cleared all state and started location');
        }
      }
    });
  }

  @override
  void didUpdateWidget(ParkingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only clear state when vehicle actually changes
    if (oldWidget.vehicle.licensePlate != widget.vehicle.licensePlate ||
        oldWidget.vehicle.type != widget.vehicle.type) {
      if (kDebugMode) {
        print(
            '🔄 ParkingScreen - Vehicle changed from ${oldWidget.vehicle.licensePlate} (type: ${oldWidget.vehicle.type}) to ${widget.vehicle.licensePlate} (type: ${widget.vehicle.type})');
        print(
            '🔄 ParkingScreen.didUpdateWidget - Clearing state due to vehicle change');
      }

      // Clear state only on vehicle change
      ref.read(parkingProvider.notifier).forceClear();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (kDebugMode) {
      print('🔄 ParkingScreen._getCurrentLocation - Iniciando...');
    }

    await ref.read(locationProvider.notifier).getCurrentLocation();
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
    final currentPosition = ref.read(currentPositionProvider);

    // Capture context before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final currentContext = context;

    if (selectedTime == null || selectedCredits == null) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Selecione o tempo de estacionamento'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (currentPosition == null) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Aguarde a obtenção da localização atual'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      // Check current balance first
      final currentBalance = ref.read(currentBalanceProvider);
      if (currentBalance == null || currentBalance.credits < selectedCredits) {
        final requiredCredits = selectedCredits;
        final availableCredits = currentBalance?.credits ?? 0;

        if (mounted) {
          scaffoldMessenger.showSnackBar(
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
        }
        return;
      }

      // First, get possible parking tickets
      final possibleParking =
          await ref.read(parkingProvider.notifier).getPossibleParking(
                licensePlate: widget.vehicle.licensePlate,
                quantity: selectedCredits.toString(),
              );

      // Check if there are sufficient tickets
      if (possibleParking.tickets.isEmpty ||
          possibleParking.tickets[0].tickets.isEmpty ||
          possibleParking.tickets[0].tickets.length < selectedCredits) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                'Créditos insuficientes para estacionar!\n'
                'Você possui: ${currentBalance.credits.toStringAsFixed(1)} créditos\n'
                'Necessário: ${selectedCredits.toStringAsFixed(1)} créditos\n'
                'Faça uma compra de créditos para continuar.',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: currentContext,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Confirmação'),
          content: Text(
            possibleParking.message ??
                'Tem certeza que deseja realizar esta ativação de seus créditos para placa ${_formatLicensePlate(widget.vehicle.licensePlate)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ).then((value) => value ?? false);

      if (confirmed != true) return;

      // Activate parking
      final parkingResponse =
          await ref.read(parkingProvider.notifier).activateParking(
                licensePlate: widget.vehicle.licensePlate,
                ticketIds: possibleParking.tickets[0].tickets,
              );

      // Reload vehicles and balance
      await Future.wait([
        ref.read(vehicleProvider.notifier).loadVehicles(),
        ref.read(balanceProvider.notifier).loadBalance(),
      ]);

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Estacionamento ativado com sucesso!\nID: ${parkingResponse.id}',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Clear selection after successful activation
        ref.read(parkingProvider.notifier).clearSelection();
        if (kDebugMode) {
          print(
              '🔄 ParkingScreen._submitParking - Cleared selection after successful activation');
        }

        // Return to home
        navigator.popUntil((route) => route.isFirst);
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

        scaffoldMessenger.showSnackBar(
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
    inspect('build');

    // Apenas observar o que é realmente necessário para o build principal
    final selectedTime = ref.watch(selectedParkingTimeProvider);

    // Debug: apenas mostrar se há posição
    if (kDebugMode) {
      print('🔄 ParkingScreen.build - Build principal executado');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatLicensePlate(widget.vehicle.licensePlate)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: () {
                if (kDebugMode) {
                  print('🔄 ParkingScreen - Botão de teste clicado');
                  print('  - Estado atual do provider:');
                  print('    - Position: ${ref.read(currentPositionProvider)}');
                  print(
                      '    - IsGetting: ${ref.read(isGettingLocationProvider)}');
                  print('    - Error: ${ref.read(locationErrorProvider)}');
                }
                _getCurrentLocation();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Map section
          Expanded(
            flex: 2,
            child: Consumer(
              builder: (context, ref, child) {
                final currentPosition = ref.watch(currentPositionProvider);
                final isGettingLocation = ref.watch(isGettingLocationProvider);
                final locationError = ref.watch(locationErrorProvider);

                // Mostrar erro de localização se houver
                if (locationError != null && mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Erro ao obter localização: $locationError'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    ref.read(locationProvider.notifier).clearError();
                  });
                }

                return ParkingMap(
                  currentPosition: currentPosition,
                  isGettingLocation: isGettingLocation,
                  onRetryLocation: _getCurrentLocation,
                );
              },
            ),
          ),

          // Parking options section
          Expanded(
            flex: 4,
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
                        await ref
                            .read(locationProvider.notifier)
                            .getCurrentLocation();
                        await ref.read(balanceProvider.notifier).loadBalance();
                      },
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: DynamicAppConfig.parkingRules,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                  'Erro ao carregar opções: ${snapshot.error}'),
                            );
                          }

                          final parkingRules = snapshot.data ?? {};
                          final vehicleRules =
                              parkingRules[widget.vehicle.type.toString()]
                                      as List<dynamic>? ??
                                  [];

                          // Debug log for loaded rules
                          if (kDebugMode) {
                            print(
                                '🅿️ ParkingScreen - Vehicle type: ${widget.vehicle.type}');
                            print(
                                '🅿️ ParkingScreen - All parking rules: $parkingRules');
                            print(
                                '🅿️ ParkingScreen - Vehicle rules: $vehicleRules');
                          }

                          if (vehicleRules.isEmpty) {
                            return const Center(
                              child: Text(
                                  'Nenhuma opção de estacionamento disponível para este veículo'),
                            );
                          }

                          return ListView.builder(
                            itemCount: vehicleRules.length,
                            itemBuilder: (context, index) {
                              final rule =
                                  vehicleRules[index] as Map<String, dynamic>;
                              final time = rule['time'] as int? ?? 0;
                              final credits = rule['credits'] as int? ?? 0;
                              final price =
                                  (rule['price'] as num?)?.toDouble() ?? 0.0;
                              final area = rule['area'] as String? ?? '';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    final currentBalance =
                                        ref.watch(currentBalanceProvider);
                                    return ParkingTimeCard(
                                      time: time,
                                      credits: credits,
                                      price: price,
                                      area: area,
                                      isSelected: selectedTime == time,
                                      availableCredits: currentBalance?.credits,
                                      onTap: () {
                                        ref
                                            .read(parkingProvider.notifier)
                                            .selectParkingTime(time, credits);
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
                    Consumer(
                      builder: (context, ref, child) {
                        final isWarningVisible =
                            ref.watch(warningVisibleProvider);

                        // Se o aviso estiver oculto, mostrar apenas um botão para exibi-lo
                        if (!isWarningVisible) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 0),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange.shade700,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Aviso de estacionamento',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(warningVisibleProvider.notifier)
                                        .show();
                                  },
                                  child: Text(
                                    'Mostrar',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            // Em telas menores, usar versão mais compacta
                            final isSmallScreen = constraints.maxWidth < 400;

                            return Consumer(
                              builder: (context, ref, child) {
                                final isWarningExpanded =
                                    ref.watch(warningExpandedProvider);

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: isSmallScreen ? 6 : 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.orange.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.orange.shade700,
                                            size: isSmallScreen ? 16 : 18,
                                          ),
                                          SizedBox(
                                              width: isSmallScreen ? 6 : 8),
                                          Expanded(
                                            child: Text(
                                              isSmallScreen
                                                  ? 'Verifique o tempo máximo na sinalização'
                                                  : 'ATENÇÃO: Verifique o tempo máximo na sinalização',
                                              style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 12 : 13,
                                                color: Colors.orange.shade800,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          // Botão para ocultar o aviso
                                          IconButton(
                                            onPressed: () {
                                              ref
                                                  .read(warningVisibleProvider
                                                      .notifier)
                                                  .hide();
                                            },
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.orange.shade600,
                                              size: 18,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 24,
                                              minHeight: 24,
                                            ),
                                          ),
                                          if (!isSmallScreen) ...[
                                            IconButton(
                                              onPressed: () {
                                                ref
                                                    .read(
                                                        warningExpandedProvider
                                                            .notifier)
                                                    .toggle();
                                              },
                                              icon: Icon(
                                                isWarningExpanded
                                                    ? Icons.keyboard_arrow_up
                                                    : Icons.keyboard_arrow_down,
                                                color: Colors.orange.shade700,
                                                size: 20,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minWidth: 24,
                                                minHeight: 24,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (isWarningExpanded &&
                                          !isSmallScreen) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Ao estacionar, verifique nas placas de sinalização o tempo máximo permitido para estacionamento nesta vaga. Próximo ao término do tempo válido de estacionamento informado, você receberá um ALERTA!',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.orange.shade800,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                      // Em telas pequenas, sempre mostrar texto compacto
                                      if (isSmallScreen) ...[
                                        Text(
                                          'Você receberá um ALERTA próximo ao vencimento conforme configurado.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange.shade700,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Parking button
                  Consumer(
                    builder: (context, ref, child) {
                      final isLoading = ref.watch(parkingLoadingProvider);

                      return SizedBox(
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
                      );
                    },
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
