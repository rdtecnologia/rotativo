import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationSettingsScreen extends ConsumerStatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  ConsumerState<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends ConsumerState<LocationSettingsScreen> {
  bool _shareLocation = false;
  bool _highAccuracy = true;
  bool _backgroundLocation = false;
  bool _automaticParking = true;
  
  String _currentLocation = 'Carregando...';
  String _locationStatus = 'Permissão não concedida';

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  @override
  Widget build(BuildContext context) {
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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Configurações de Localização',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure como o app usa sua localização',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Current location status
            _buildStatusCard(),

            const SizedBox(height: 16),

            // Location settings
            _buildSettingsCard(
              'Compartilhamento de Localização',
              [
                _buildSwitchTile(
                  title: 'Compartilhar localização',
                  subtitle: 'Permitir que o app acesse sua localização',
                  value: _shareLocation,
                  onChanged: _handleLocationToggle,
                  icon: Icons.my_location,
                ),
                if (_shareLocation) ...[
                  const Divider(),
                  _buildSwitchTile(
                    title: 'Alta precisão',
                    subtitle: 'Usar GPS para maior precisão',
                    value: _highAccuracy,
                    onChanged: (value) {
                      setState(() {
                        _highAccuracy = value;
                      });
                    },
                    icon: Icons.gps_fixed,
                  ),
                  const Divider(),
                  _buildSwitchTile(
                    title: 'Localização em segundo plano',
                    subtitle: 'Continuar rastreando quando o app estiver fechado',
                    value: _backgroundLocation,
                    onChanged: (value) {
                      setState(() {
                        _backgroundLocation = value;
                      });
                    },
                    icon: Icons.location_history,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            _buildSettingsCard(
              'Recursos Automáticos',
              [
                _buildSwitchTile(
                  title: 'Detecção automática de estacionamento',
                  subtitle: 'Identificar automaticamente quando você estaciona',
                  value: _automaticParking,
                  onChanged: (value) {
                    setState(() {
                      _automaticParking = value;
                    });
                  },
                  icon: Icons.directions_car,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Privacy info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.privacy_tip,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Sua Privacidade',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Sua localização é usada apenas para funcionalidades do app\n'
                    '• Não compartilhamos seus dados com terceiros\n'
                    '• Você pode desativar a qualquer momento\n'
                    '• Os dados são criptografados e seguros',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Test location button
            if (_shareLocation) ...[
              ElevatedButton.icon(
                onPressed: _testLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Obter localização atual'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final statusColor = _shareLocation ? Colors.green : Colors.orange;
    final statusIcon = _shareLocation ? Icons.check_circle : Icons.warning;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Status da Localização',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Status: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                _locationStatus,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Localização: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Expanded(
                child: Text(
                  _currentLocation,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _handleLocationToggle(bool value) async {
    if (value) {
      // Request location permission
      final hasPermission = await _requestLocationPermission();
      if (hasPermission) {
        setState(() {
          _shareLocation = true;
          _locationStatus = 'Ativo';
        });
        _getCurrentLocation();
      } else {
        _showPermissionDialog();
      }
    } else {
      setState(() {
        _shareLocation = false;
        _locationStatus = 'Desativado';
        _currentLocation = 'Localização desativada';
      });
    }
  }

  Future<bool> _requestLocationPermission() async {
    // TODO: Implement actual location permission request
    // final permission = await Permission.location.request();
    // return permission.isGranted;
    
    // Simulate permission request
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Simulating granted permission
  }

  void _checkLocationStatus() async {
    // TODO: Check actual location permission status
    setState(() {
      _locationStatus = 'Verificando...';
    });
    
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _locationStatus = 'Permissão não concedida';
      _currentLocation = 'Ative a localização para ver';
    });
  }

  void _getCurrentLocation() async {
    setState(() {
      _currentLocation = 'Obtendo localização...';
    });

    // TODO: Get actual location
    // final position = await Geolocator.getCurrentPosition();
    // setState(() {
    //   _currentLocation = '${position.latitude}, ${position.longitude}';
    // });

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _currentLocation = 'Ouro Preto, MG';
    });
  }

  void _testLocation() {
    _getCurrentLocation();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.location_searching, color: Colors.white),
            SizedBox(width: 12),
            Text('Buscando localização atual...'),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissão de Localização'),
        content: const Text(
          'Para usar este recurso, você precisa conceder permissão de localização nas configurações do dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Open app settings
              // openAppSettings();
            },
            child: const Text('Configurações'),
          ),
        ],
      ),
    );
  }
}