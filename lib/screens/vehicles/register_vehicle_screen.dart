import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import '../../models/vehicle_models.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/vehicle_service.dart';
import '../../utils/formatters.dart';
import 'dart:async'; // Added for Timer

class RegisterVehicleScreen extends ConsumerStatefulWidget {
  const RegisterVehicleScreen({super.key});

  @override
  ConsumerState<RegisterVehicleScreen> createState() => _RegisterVehicleScreenState();
}

class _RegisterVehicleScreenState extends ConsumerState<RegisterVehicleScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  int _selectedVehicleType = 1; // 1 = carro, 2 = moto
  bool _isEditing = false;
  String? _editingLicensePlate;
  bool _isRetrying = false; // Novo: indica se está tentando novamente

  // Tipos de veículo fixos (apenas carro e moto)
  final List<Map<String, dynamic>> _vehicleTypes = [
    {'id': 1, 'name': 'Carro', 'icon': '🚗'},
    {'id': 2, 'name': 'Moto', 'icon': '🏍️'},
  ];

  @override
  void initState() {
    super.initState();
    // Carrega a lista de veículos ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vehicleProvider.notifier).loadVehicles();
    });
  }

  void _onVehicleTypeSelected(int typeId) {
    setState(() {
      _selectedVehicleType = typeId;
    });
  }

  void _onPlateChanged(String? value) async {
    if (value != null) {
      // Converte para maiúsculo imediatamente
      final upperValue = value.toUpperCase();
      
      // Atualiza o campo com o valor em maiúsculo
      if (upperValue != value) {
        // Usa um pequeno delay para evitar conflitos
        Future.delayed(const Duration(milliseconds: 10), () {
          if (mounted) {
            _formKey.currentState?.fields['licensePlate']?.didChange(upperValue);
          }
        });
        return; // Retorna para evitar processamento duplo
      }
      
      final cleanPlate = upperValue.replaceAll(RegExp(r'[^A-Z0-9]'), '');
      
      // Check if plate has valid length for either format
      if (cleanPlate.length == 7 || cleanPlate.length == 8) {
        // Verifica se já existe um veículo com esta placa
        final vehicles = ref.read(vehicleProvider).vehicles;
        final existingVehicle = vehicles.firstWhere(
          (v) => v.licensePlate.replaceAll(RegExp(r'[^A-Z0-9]'), '') == cleanPlate,
          orElse: () => Vehicle(
            licensePlate: '',
            type: 0,
          ),
        );

        if (existingVehicle.licensePlate.isNotEmpty && !_isEditing) {
          // Se não estiver editando, mostra erro de duplicata
          _formKey.currentState?.fields['licensePlate']?.invalidate('Veículo já cadastrado');
        }
        
        // Se a placa está completa (8 caracteres), busca o modelo automaticamente
        if (cleanPlate.length == 8 && !_isEditing) {
          await _getModelByPlate(cleanPlate);
        }
      }
    }
  }

  Future<void> _getModelByPlate(String cleanPlate) async {
    try {
      debugPrint('🔍 Buscando modelo para placa: $cleanPlate');
      
      // Aqui você pode implementar a chamada para buscar o modelo pela placa
      // Por enquanto, vamos simular com um delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Simula busca do modelo (substitua pela chamada real da API)
      final mockModel = _getMockModelByPlate(cleanPlate);
      if (mockModel != null) {
        debugPrint('✅ Modelo encontrado: $mockModel');
        _formKey.currentState?.fields['model']?.didChange(mockModel);
        
        // Mostra toast informativo
        Fluttertoast.showToast(
          msg: 'Modelo preenchido automaticamente: $mockModel',
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao buscar modelo: $e');
    }
  }

  String? _getMockModelByPlate(String cleanPlate) {
    // Simula busca de modelo por placa (substitua pela API real)
    final mockModels = {
      'AAA1234': 'HONDA CIVIC',
      'BBB5678': 'TOYOTA COROLLA',
      'CCC9012': 'VOLKSWAGEN GOLF',
      'DDD3456': 'FORD FOCUS',
      'EEE7890': 'CHEVROLET CRUZE',
    };
    
    return mockModels[cleanPlate];
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      
      final licensePlate = (formData['licensePlate'] as String)
          .replaceAll(RegExp(r'[^A-Z0-9]'), '')
          .toUpperCase();
      
      // Validate plate format before submitting
      if (!AppFormatters.isValidPlateFormat(licensePlate)) {
        Fluttertoast.showToast(
          msg: 'Formato de placa inválido',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      // Verifica se já existe um veículo com esta placa (exceto se estiver editando)
      if (!_isEditing) {
        final vehicles = ref.read(vehicleProvider).vehicles;
        final existingVehicle = vehicles.firstWhere(
          (v) => v.licensePlate.replaceAll(RegExp(r'[^A-Z0-9]'), '') == licensePlate,
          orElse: () => Vehicle(
            licensePlate: '',
            type: 0,
          ),
        );

        if (existingVehicle.licensePlate.isNotEmpty) {
          Fluttertoast.showToast(
            msg: 'Veículo já cadastrado',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return;
        }
      }
      
      try {
        if (_isEditing) {
          // Atualiza veículo existente
          final updateRequest = VehicleUpdateRequest(
            model: formData['model'] as String? ?? '',
          );
          
          debugPrint('🔄 Atualizando veículo: $_editingLicensePlate');
          await ref.read(vehicleProvider.notifier).updateVehicle(_editingLicensePlate!, updateRequest);
          
          Fluttertoast.showToast(
            msg: 'Veículo atualizado com sucesso!',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else {
          // Cria novo veículo
          final createRequest = VehicleCreateRequest(
            licensePlate: licensePlate,
            model: formData['model'] as String? ?? '',
            type: _selectedVehicleType,
          );
          
          debugPrint('🆕 Criando veículo: $licensePlate, Modelo: $createRequest.model');
          await ref.read(vehicleProvider.notifier).createVehicle(createRequest);
          
          Fluttertoast.showToast(
            msg: 'Veículo cadastrado com sucesso!',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        }
        
        // Refresh vehicle list
        ref.read(vehicleProvider.notifier).loadVehicles();
        
        // Reset form and go back to normal mode
        _resetForm();
        
      } catch (e) {
        debugPrint('❌ Erro ao ${_isEditing ? 'atualizar' : 'cadastrar'} veículo: $e');
        debugPrint('❌ Stack trace: ${StackTrace.current}');
        
        String errorMessage = 'Erro desconhecido';
        
        // Trata diferentes tipos de erro
        if (e.toString().contains('503')) {
          errorMessage = 'Servidor temporariamente indisponível. Tente novamente em alguns minutos.';
        } else if (e.toString().contains('400')) {
          errorMessage = 'Dados inválidos. Verifique as informações e tente novamente.';
        } else if (e.toString().contains('401')) {
          errorMessage = 'Sessão expirada. Faça login novamente.';
        } else if (e.toString().contains('403')) {
          errorMessage = 'Acesso negado. Verifique suas permissões.';
        } else if (e.toString().contains('404')) {
          errorMessage = 'Serviço não encontrado.';
        } else if (e.toString().contains('500')) {
          errorMessage = 'Erro interno do servidor. Tente novamente mais tarde.';
        } else if (e.toString().contains('Exception:')) {
          errorMessage = e.toString().split('Exception: ').last;
        } else {
          errorMessage = e.toString();
        }
        
        // Mostra mensagem de erro mais amigável
        Fluttertoast.showToast(
          msg: errorMessage,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
        
        // Se for erro 503, mostra também um SnackBar com botão de retry
        if (e.toString().contains('503')) {
          setState(() {
            _isRetrying = true;
          });
          
          // Captura o contexto antes do async gap
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Tentar Novamente',
                textColor: Colors.white,
                onPressed: () {
                  // Tenta novamente automaticamente
                  _handleSubmit();
                },
              ),
            ),
          );
          
          // Reseta o estado de retry após 3 segundos
          _resetRetryState();
        }
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _isEditing = false;
      _editingLicensePlate = null;
      _selectedVehicleType = 1;
    });
  }

  void _resetRetryState() {
    // Reseta o estado de retry após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    });
  }

  void _editVehicle(Vehicle vehicle) {
    setState(() {
      _isEditing = true;
      _editingLicensePlate = vehicle.licensePlate;
      _selectedVehicleType = vehicle.type;
    });
    
    _formKey.currentState?.fields['licensePlate']?.didChange(vehicle.licensePlate);
    _formKey.currentState?.fields['model']?.didChange(vehicle.model ?? '');
  }

  Future<void> _deleteVehicle(Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir o veículo ${vehicle.licensePlate}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await ref.read(vehicleProvider.notifier).deleteVehicle(vehicle.licensePlate);
        Fluttertoast.showToast(
          msg: 'Veículo excluído com sucesso!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        // Refresh vehicle list
        ref.read(vehicleProvider.notifier).loadVehicles();
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Erro ao excluir veículo: ${e.toString()}',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(vehicleListProvider);
    final isLoading = ref.watch(vehicleLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Veículo' : 'Cadastrar Veículo',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _resetForm,
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Type Selection
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selecione o tipo de veículo:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _vehicleTypes.map((type) {
                        final isSelected = _selectedVehicleType == type['id'];
                        return GestureDetector(
                          onTap: () => _onVehicleTypeSelected(type['id']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  type['icon'],
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  type['name'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Form
            FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  // License Plate and Model Fields in the same card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // License Plate Field
                          FormBuilderTextField(
                            name: 'licensePlate',
                            enabled: !_isEditing, // Não permite editar placa
                            decoration: InputDecoration(
                              labelText: 'Placa do veículo',
                              hintText: 'ABC1234 ou ABC1D23',
                              prefixIcon: const Icon(Icons.directions_car),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              helperText: 'Formato antigo: ABC1234 | Mercosul: ABC1D23',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                              LengthLimitingTextInputFormatter(8), // Limita a 8 caracteres
                            ],
                            textCapitalization: TextCapitalization.characters,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: 'Placa é obrigatória',
                              ),
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Placa é obrigatória';
                                }
                                
                                final cleanPlate = value.replaceAll(RegExp(r'[^A-Z0-9]'), '');
                                if (cleanPlate.length != 7 && cleanPlate.length != 8) {
                                  return 'Placa deve ter 7 (antiga) ou 8 (Mercosul) caracteres';
                                }
                                
                                if (!AppFormatters.isValidPlateFormat(value)) {
                                  return 'Formato de placa inválido';
                                }
                                
                                return null;
                              },
                            ]),
                            onChanged: _onPlateChanged,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Model Field (obrigatório)
                          FormBuilderTextField(
                            name: 'model',
                            decoration: InputDecoration(
                              labelText: 'Modelo do veículo *',
                              hintText: 'Ex: Honda Civic',
                              prefixIcon: const Icon(Icons.car_rental),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: 'Modelo é obrigatório',
                              ),
                              FormBuilderValidators.minLength(
                                2,
                                errorText: 'Modelo deve ter pelo menos 2 caracteres',
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (isLoading || _isRetrying) ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: (isLoading || _isRetrying)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _isRetrying ? 'Tentando novamente...' : 'Processando...',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              _isEditing ? 'Atualizar Veículo' : 'Cadastrar Veículo',
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

            const SizedBox(height: 32),

            // Lista de veículos cadastrados
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Veículos Cadastrados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (vehicles.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.directions_car_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Nenhum veículo cadastrado',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: vehicles.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final vehicle = vehicles[index];
                          final vehicleType = _vehicleTypes.firstWhere(
                            (type) => type['id'] == vehicle.type,
                            orElse: () => {'name': 'Desconhecido', 'icon': '❓'},
                          );
                          
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                child: Text(
                                  vehicleType['icon'],
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              title: Text(
                                vehicle.licensePlate,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vehicleType['name'],
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (vehicle.model?.isNotEmpty == true)
                                    Text(
                                      vehicle.model!,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _editVehicle(vehicle),
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    tooltip: 'Editar',
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteVehicle(vehicle),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Excluir',
                                  ),
                                ],
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
      ),
    );
  }
}

