import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/parking_models.dart';
import '../../providers/parking_provider.dart';
import '../../utils/formatters.dart';

class ActivationDetailScreen extends ConsumerStatefulWidget {
  final String activationId;

  const ActivationDetailScreen({
    Key? key,
    required this.activationId,
  }) : super(key: key);

  @override
  ConsumerState<ActivationDetailScreen> createState() => _ActivationDetailScreenState();
}

class _ActivationDetailScreenState extends ConsumerState<ActivationDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load activation details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(parkingProvider.notifier).getActivationDetail(widget.activationId);
    });
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

  Future<void> _openMap(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o mapa'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(ActivationDetail activation) {
    if (!activation.hasLocation) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.location_off,
              color: Colors.grey,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Localização não disponível',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Localização do estacionamento',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Lat: ${activation.latitudeDouble?.toStringAsFixed(6) ?? 'N/A'}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
            ),
          ),
          Text(
            'Lng: ${activation.longitudeDouble?.toStringAsFixed(6) ?? 'N/A'}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openMap(
                activation.latitudeDouble!,
                activation.longitudeDouble!,
              ),
              icon: const Icon(Icons.map, size: 18),
              label: const Text('Ver no Mapa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activationDetail = ref.watch(activationDetailProvider);
    final isLoading = ref.watch(parkingProvider).isLoadingActivationDetail;
    final error = ref.watch(parkingErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Ativação'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Erro ao carregar detalhes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(parkingProvider.notifier).getActivationDetail(widget.activationId);
                        },
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
              )
            else if (activationDetail != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.confirmation_number,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ativação #${activationDetail.id}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          _buildDetailItem(
                            'Placa:',
                            _formatLicensePlate(activationDetail.licensePlate),
                          ),
                          
                          _buildDetailItem(
                            'Tipo de veículo:',
                            activationDetail.product.vehicleType == 1 ? 'Carro' : 'Moto',
                          ),
                          
                          _buildDetailItem(
                            'Data da ativação:',
                            AppFormatters.formatDateTime(activationDetail.transactionDate),
                          ),
                          
                          _buildDetailItem(
                            'Tipo da ativação:',
                            activationDetail.product.description,
                          ),
                          
                          _buildDetailItem(
                            'Tempo selecionado:',
                            _formatParkingTime(activationDetail.parkingTime),
                          ),
                          
                          // Status do estacionamento
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: const Text(
                                  'Status:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getParkingStatusColor(activationDetail),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getParkingStatusText(activationDetail),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          if (_isParkingActive(activationDetail)) ...[
                            _buildDetailItem(
                              'Tempo restante:',
                              _formatParkingTime(_getRemainingMinutes(activationDetail)),
                            ),
                          ],
                          
                          if (activationDetail.origin.isNotEmpty)
                            _buildDetailItem(
                              'Origem:',
                              activationDetail.origin,
                            ),
                          
                          if (activationDetail.device.isNotEmpty)
                            _buildDetailItem(
                              'Dispositivo:',
                              activationDetail.device,
                            ),
                          
                          if (activationDetail.area != null && activationDetail.area!.isNotEmpty)
                            _buildDetailItem(
                              'Área:',
                              activationDetail.area!,
                            ),
                          
                          if (activationDetail.scheduledAt != null)
                            _buildDetailItem(
                              'Agendado para:',
                              AppFormatters.formatDateTime(activationDetail.scheduledAt!),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Informação sobre status e atualização
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Para mostrar corretamente o status de ativação, mantenha a data e hora do seu celular sempre atualizadas.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Location section
                  const Text(
                    'Localização',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  _buildLocationSection(activationDetail),
                ],
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Detalhes da ativação não encontrados',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares para status do estacionamento
  bool _isParkingActive(ActivationDetail activation) {
    final expirationTime = activation.transactionDate.add(Duration(minutes: activation.parkingTime));
    return DateTime.now().isBefore(expirationTime);
  }

  int _getRemainingMinutes(ActivationDetail activation) {
    final expirationTime = activation.transactionDate.add(Duration(minutes: activation.parkingTime));
    final remaining = expirationTime.difference(DateTime.now()).inMinutes;
    return remaining > 0 ? remaining : 0;
  }

  String _getParkingStatusText(ActivationDetail activation) {
    if (_isParkingActive(activation)) {
      final remaining = _getRemainingMinutes(activation);
      if (remaining <= 15) {
        return 'Expirando em ${remaining}min';
      } else if (remaining <= 30) {
        return 'Expira em ${remaining}min';
      } else {
        return 'Ativo';
      }
    } else {
      return 'Expirado';
    }
  }

  Color _getParkingStatusColor(ActivationDetail activation) {
    if (_isParkingActive(activation)) {
      final remaining = _getRemainingMinutes(activation);
      if (remaining <= 15) {
        return Colors.red;
      } else if (remaining <= 30) {
        return Colors.orange;
      } else {
        return Colors.green;
      }
    } else {
      return Colors.grey;
    }
  }
}
