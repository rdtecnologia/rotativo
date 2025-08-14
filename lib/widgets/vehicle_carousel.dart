import 'package:flutter/material.dart';
import '../models/vehicle_models.dart';
import '../widgets/parking_timer.dart';

class VehicleCarousel extends StatefulWidget {
  final List<Vehicle> vehicles;
  final Function(Vehicle) onVehicleTap;

  const VehicleCarousel({
    super.key,
    required this.vehicles,
    required this.onVehicleTap,
  });

  @override
  State<VehicleCarousel> createState() => _VehicleCarouselState();
}

class _VehicleCarouselState extends State<VehicleCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85); // Aumentado de 0.8 para 0.85 para melhor uso do espaço
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.vehicles.isEmpty) {
      return const NoVehiclesWidget();
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = widget.vehicles[index];
              return VehicleCard(
                vehicle: vehicle,
                onTap: () => widget.onVehicleTap(vehicle),
              );
            },
          ),
        ),
        
        // Page indicators
        if (widget.vehicles.length > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.vehicles.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    entry.key,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == entry.key
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  IconData _getVehicleIcon(int vehicleType) {
    switch (vehicleType) {
      case 1:
        return Icons.directions_car; // Carro
      case 2:
        return Icons.motorcycle; // Moto
      case 3:
        return Icons.local_shipping; // Caminhão
      case 4:
        return Icons.motorcycle; // Motocicleta
      case 5:
        return Icons.local_shipping; // Caminhão Grande
      case 6:
        return Icons.directions_bus; // Ônibus
      case 7:
        return Icons.directions_bus; // Microônibus
      case 8:
        return Icons.directions_car; // Van
      case 9:
        return Icons.motorcycle; // Triciclo
      case 10:
        return Icons.directions_car; // Quadriciclo
      default:
        return Icons.directions_car; // Padrão
    }
  }

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
      case 6:
        return 'Ônibus';
      case 7:
        return 'Microônibus';
      case 8:
        return 'Van';
      case 9:
        return 'Triciclo';
      case 10:
        return 'Quadriciclo';
      default:
        return 'Veículo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // ESPAÇO SUPERIOR - Afasta elementos da borda superior
              const SizedBox(height: 16),
              
              // PARTE SUPERIOR: Dados do carro
              Column(
                children: [
                  // Vehicle icon based on type
                  Icon(
                    _getVehicleIcon(vehicle.type),
                    size: 56,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  
                  // License plate
                  Text(
                    vehicle.licensePlate,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Vehicle details (modelo/marca)
                  if (vehicle.model != null || vehicle.brand != null) ...[
                    Text(
                      '${vehicle.brand ?? ''} ${vehicle.model ?? ''}'.trim(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                  
                  if (vehicle.color != null) ...[
                    Text(
                      vehicle.color!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
              
              // Botão Estacionar logo abaixo do modelo
              const SizedBox(height: 16),
              
              // Action button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'ESTACIONAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              
              // ESPAÇO FLEXÍVEL NO MEIO - Se adapta à resolução
              const Expanded(child: SizedBox()),
              
              // PARTE INFERIOR: Timer
              Column(
                children: [
                  // Parking timer (se houver estacionamento ativo)
                  Container(
                    width: double.infinity,
                    height: 80,
                    child: ParkingTimer(
                      vehicle: vehicle,
                      width: double.infinity,
                      height: 80,
                    ),
                  ),
                  
                  // ESPAÇO INFERIOR - Afasta elementos da borda inferior
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoVehiclesWidget extends StatelessWidget {
  const NoVehiclesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum veículo cadastrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Cadastre seus veículos para começar a usar o app',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to add vehicle screen
            },
            icon: const Icon(Icons.add),
            label: const Text('Cadastrar Veículo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}