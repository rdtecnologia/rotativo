import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingMap extends StatefulWidget {
  final Position? currentPosition;
  final bool isGettingLocation;
  final VoidCallback onRetryLocation;
  final bool shareLocation;

  const ParkingMap({
    super.key,
    this.currentPosition,
    required this.isGettingLocation,
    required this.onRetryLocation,
    required this.shareLocation,
  });

  @override
  State<ParkingMap> createState() => _ParkingMapState();
}

class _ParkingMapState extends State<ParkingMap> {
  bool _mapLoadError = false;
  bool _showLocationTimeout = false;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _startLocationTimer();
  }

  @override
  void didUpdateWidget(ParkingMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset timeout if location was found
    if (widget.currentPosition != null && oldWidget.currentPosition == null) {
      _cancelLocationTimer();
      setState(() {
        _showLocationTimeout = false;
      });
    }

    // Restart timer if started getting location again
    if (widget.isGettingLocation && !oldWidget.isGettingLocation) {
      _startLocationTimer();
    }
  }

  @override
  void dispose() {
    _cancelLocationTimer();
    super.dispose();
  }

  void _startLocationTimer() {
    _cancelLocationTimer();
    if (widget.shareLocation &&
        widget.currentPosition == null &&
        widget.isGettingLocation) {
      _locationTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && widget.currentPosition == null) {
          setState(() {
            _showLocationTimeout = true;
          });
        }
      });
    }
  }

  void _cancelLocationTimer() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Stack(
        children: [
          // Se não está compartilhando localização, mostrar apenas ícone
          if (!widget.shareLocation)
            Stack(
              children: [
                // Background color base (tom claro da cor primária)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                ),
                // Background image translúcida
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/parking_background.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Color.fromRGBO(255, 255, 255, 0.3),
                        BlendMode.modulate,
                      ),
                    ),
                  ),
                ),
                // Gradient overlay suave
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        Theme.of(context).primaryColor.withValues(alpha: 0.15),
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                // Ícone
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: Center(
                    child: Icon(
                      Icons.location_pin,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            )
          // Real Google Map
          else if (widget.currentPosition != null && !_mapLoadError)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.currentPosition!.latitude,
                  widget.currentPosition!.longitude,
                ),
                zoom: 16.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                debugPrint('✅ Google Maps carregado com sucesso');
                debugPrint(
                    '📍 Posição: ${widget.currentPosition!.latitude}, ${widget.currentPosition!.longitude}');

                // Verificar se o mapa carregou corretamente após 5 segundos
                Future.delayed(const Duration(seconds: 5), () {
                  if (mounted) {
                    debugPrint(
                        '🔍 Verificando se o mapa carregou corretamente...');
                    debugPrint(
                        '💡 Se o mapa estiver cinza, verifique as permissões da API Key no Google Cloud Console');
                  }
                });
              },
              mapType: MapType.normal,
              liteModeEnabled: false,
              trafficEnabled: false,
              buildingsEnabled: true,
              indoorViewEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('current_location'),
                  position: LatLng(
                    widget.currentPosition!.latitude,
                    widget.currentPosition!.longitude,
                  ),
                  infoWindow: InfoWindow(
                    title: 'Sua localização atual',
                    snippet:
                        'Lat: ${widget.currentPosition!.latitude.toStringAsFixed(6)}\nLng: ${widget.currentPosition!.longitude.toStringAsFixed(6)}',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
            )
          else if (widget.currentPosition != null && _mapLoadError)
            // Fallback quando há erro no mapa
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.red.shade100,
                    Colors.red.shade200,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 48,
                      color: Colors.red[600],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Erro ao carregar o mapa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Verifique as permissões da API Key\nno Google Cloud Console',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _mapLoadError = false;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar Novamente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (widget.isGettingLocation && !_showLocationTimeout)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade100,
                    Colors.blue.shade200,
                  ],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Obtendo sua localização...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Stack(
              children: [
                // Background color base (tom claro da cor primária)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                ),
                // Background image translúcida
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/parking_background.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Color.fromRGBO(255, 255, 255, 0.3),
                        BlendMode.modulate,
                      ),
                    ),
                  ),
                ),
                // Gradient overlay suave
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        Theme.of(context).primaryColor.withValues(alpha: 0.15),
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                // Ícone
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: Center(
                    child: Icon(
                      Icons.location_pin,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),

          // Info overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Prossiga com a ativação.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
