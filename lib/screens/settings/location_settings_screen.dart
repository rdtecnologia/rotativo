import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class LocationSettingsScreen extends ConsumerStatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  ConsumerState<LocationSettingsScreen> createState() =>
      _LocationSettingsScreenState();
}

class _LocationSettingsScreenState
    extends ConsumerState<LocationSettingsScreen> {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current location status
              Card(
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
                        _locationStatus,
                        _getStatusColor(_locationStatus),
                      ),

                      const SizedBox(height: 12),

                      // Current location
                      _buildStatusItem(
                        'Localização Atual',
                        _currentLocation,
                        Colors.grey[700]!,
                      ),

                      const SizedBox(height: 16),

                      // Test location button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _testLocation,
                          icon: const Icon(Icons.location_searching),
                          label: const Text('Testar Localização'),
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
              ),

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
                      subtitle:
                          'Continuar rastreando quando o app estiver fechado',
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
                    title: 'Estacionamento automático',
                    subtitle: 'Detectar automaticamente quando você estacionar',
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

              const SizedBox(height: 20),

              // Information card
              Card(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(String title, List<Widget> children) {
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
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
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
    return Row(
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
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
      ],
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
    try {
      debugPrint('🔍 LocationSettings: Verificando serviços de localização...');

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint(
          '🔍 LocationSettings: Serviços de localização habilitados: $serviceEnabled');

      if (!serviceEnabled) {
        debugPrint('❌ LocationSettings: Serviços de localização desabilitados');
        // Show dialog to enable location services
        if (mounted) {
          _showLocationServicesDialog();
        }
        return false;
      }

      debugPrint('🔍 LocationSettings: Verificando permissões...');

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('🔍 LocationSettings: Permissão atual: $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('🔍 LocationSettings: Solicitando permissão...');
        try {
          permission = await Geolocator.requestPermission();
          debugPrint('🔍 LocationSettings: Nova permissão: $permission');
        } catch (e) {
          debugPrint('❌ LocationSettings: Erro ao solicitar permissão: $e');
          return false;
        }

        if (permission == LocationPermission.denied) {
          debugPrint('❌ LocationSettings: Permissão negada pelo usuário');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ LocationSettings: Permissão negada permanentemente');
        if (mounted) {
          _showPermanentDenialDialog();
        }
        return false;
      }

      debugPrint('✅ LocationSettings: Permissão concedida: $permission');
      return true;
    } catch (e, stackTrace) {
      debugPrint(
          '❌ LocationSettings: Erro ao solicitar permissão de localização: $e');
      debugPrint('❌ LocationSettings: Stack trace: $stackTrace');
      return false;
    }
  }

  void _checkLocationStatus() async {
    setState(() {
      _locationStatus = 'Verificando...';
    });

    try {
      debugPrint('🔍 LocationSettings: Iniciando verificação de status...');

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('🔍 LocationSettings: Serviços habilitados: $serviceEnabled');

      if (!serviceEnabled) {
        debugPrint('❌ LocationSettings: Serviços desabilitados');
        setState(() {
          _locationStatus = 'Serviços de localização desabilitados';
          _currentLocation = 'Ative a localização nas configurações';
        });
        return;
      }

      debugPrint('🔍 LocationSettings: Verificando permissões...');

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('🔍 LocationSettings: Permissão: $permission');

      switch (permission) {
        case LocationPermission.denied:
          debugPrint('❌ LocationSettings: Permissão negada');
          setState(() {
            _locationStatus = 'Permissão negada';
            _currentLocation = 'Permissão necessária para funcionar';
          });
          break;
        case LocationPermission.deniedForever:
          debugPrint('❌ LocationSettings: Permissão negada permanentemente');
          setState(() {
            _locationStatus = 'Permissão negada permanentemente';
            _currentLocation = 'Configure nas configurações do app';
          });
          break;
        case LocationPermission.whileInUse:
        case LocationPermission.always:
          debugPrint('✅ LocationSettings: Permissão concedida');
          setState(() {
            _locationStatus = 'Permissão concedida';
            _shareLocation = true;
          });
          _getCurrentLocation();
          break;
        case LocationPermission.unableToDetermine:
          debugPrint('❓ LocationSettings: Não foi possível determinar');
          setState(() {
            _locationStatus = 'Não foi possível determinar';
            _currentLocation = 'Erro ao verificar permissões';
          });
          break;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ LocationSettings: Erro ao verificar status: $e');
      debugPrint('❌ LocationSettings: Stack trace: $stackTrace');
      setState(() {
        _locationStatus = 'Erro ao verificar';
        _currentLocation = 'Erro desconhecido';
      });
    }
  }

  void _getCurrentLocation() async {
    setState(() {
      _currentLocation = 'Obtendo localização...';
    });

    try {
      debugPrint('🔍 LocationSettings: Solicitando localização atual...');

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy:
            _highAccuracy ? LocationAccuracy.high : LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint(
          '✅ LocationSettings: Localização obtida: ${position.latitude}, ${position.longitude}');

      setState(() {
        _currentLocation =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });
    } catch (e, stackTrace) {
      debugPrint('❌ LocationSettings: Erro ao obter localização: $e');
      debugPrint('❌ LocationSettings: Stack trace: $stackTrace');

      String errorMessage = 'Erro ao obter localização';

      // Provide more specific error messages
      if (e.toString().contains('Location service is disabled')) {
        errorMessage = 'Serviços de localização desabilitados';
      } else if (e.toString().contains('Location permission denied')) {
        errorMessage = 'Permissão de localização negada';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Timeout ao obter localização';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Erro de rede';
      }

      setState(() {
        _currentLocation = errorMessage;
      });
    }
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

  void _showLocationServicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Serviços de Localização Desabilitados'),
        content: const Text(
          'Para usar o compartilhamento de localização, você precisa habilitar os serviços de localização nas configurações do dispositivo.',
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

  void _showPermanentDenialDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissão Negada Permanentemente'),
        content: const Text(
          'A permissão de localização foi negada permanentemente. Você precisará configurar manualmente nas configurações do dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
