import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/location_settings_provider.dart';

class LocationSettingsScreen extends ConsumerWidget {
  const LocationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    inspect('build');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compartilhar localização'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current location status - Consumer específico
              const _LocationStatusCard(),

              const SizedBox(height: 16),

              // Location settings - Consumer específico
              const _LocationSettingsCard(),

              const SizedBox(height: 16),

              // Automatic features - Consumer específico
              const _AutomaticFeaturesCard(),

              const SizedBox(height: 20),

              // Information card - Widget estático
              _buildInformationCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformationCard(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.blue.shade700,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'A localização é necessária para registrar onde você estacionou e fornecer serviços baseados em localização.',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget específico para status de localização
class _LocationStatusCard extends ConsumerWidget {
  const _LocationStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationSettingsProvider);
    final locationNotifier = ref.read(locationSettingsProvider.notifier);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.my_location,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Status da Localização',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location status
            _buildStatusItem(
              'Status',
              locationState.locationStatus,
              _getStatusColor(locationState.locationStatus),
            ),

            const SizedBox(height: 12),

            // Current location
            _buildStatusItem(
              'Localização Atual',
              locationState.currentLocation,
              Colors.grey[700]!,
            ),

            const SizedBox(height: 16),

            // Test location button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: locationState.isLoading
                    ? null
                    : () => locationNotifier.testLocation(),
                icon: locationState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.location_searching),
                label: Text(
                  locationState.isLoading
                      ? 'Testando...'
                      : 'Testar Localização',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ativo':
        return Colors.green;
      case 'verificando...':
        return Colors.orange;
      case 'permissão não concedida':
        return Colors.red;
      case 'desativado':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

// Widget específico para configurações de localização
class _LocationSettingsCard extends ConsumerWidget {
  const _LocationSettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationSettingsProvider);
    final locationNotifier = ref.read(locationSettingsProvider.notifier);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compartilhamento de Localização',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Compartilhar localização',
              subtitle: 'Permitir que o app acesse sua localização',
              value: locationState.shareLocation,
              onChanged: (value) async =>
                  await locationNotifier.toggleLocationSharing(value),
              icon: Icons.my_location,
            ),
            if (locationState.shareLocation) ...[
              const Divider(),
              _buildSwitchTile(
                title: 'Alta precisão',
                subtitle: 'Usar GPS para maior precisão',
                value: locationState.highAccuracy,
                onChanged: (value) async {
                  locationNotifier.setHighAccuracy(value);
                },
                icon: Icons.gps_fixed,
              ),
              const Divider(),
              _buildSwitchTile(
                title: 'Localização em segundo plano',
                subtitle: 'Continuar rastreando quando o app estiver fechado',
                value: locationState.backgroundLocation,
                onChanged: (value) async {
                  locationNotifier.setBackgroundLocation(value);
                },
                icon: Icons.location_history,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required dynamic Function(bool) onChanged,
    required IconData icon,
  }) {
    return Builder(
      builder: (context) => Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (value) {
              final result = onChanged(value);
              if (result is Future) {
                // Ignora o resultado se for assíncrono
              }
            },
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}

// Widget específico para recursos automáticos
class _AutomaticFeaturesCard extends ConsumerWidget {
  const _AutomaticFeaturesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationSettingsProvider);
    final locationNotifier = ref.read(locationSettingsProvider.notifier);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recursos Automáticos',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Estacionamento automático',
              subtitle: 'Detectar automaticamente quando você estacionar',
              value: locationState.automaticParking,
              onChanged: (value) async {
                locationNotifier.setAutomaticParking(value);
              },
              icon: Icons.directions_car,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required dynamic Function(bool) onChanged,
    required IconData icon,
  }) {
    return Builder(
      builder: (context) => Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (value) {
              final result = onChanged(value);
              if (result is Future) {
                // Ignora o resultado se for assíncrono
              }
            },
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
