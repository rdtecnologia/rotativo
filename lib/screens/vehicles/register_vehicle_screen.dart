import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/vehicle_registration_models.dart';
import '../../providers/vehicle_registration_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../utils/formatters.dart';
import 'package:flutter/services.dart';

class RegisterVehicleScreen extends ConsumerStatefulWidget {
  const RegisterVehicleScreen({super.key});

  @override
  ConsumerState<RegisterVehicleScreen> createState() => _RegisterVehicleScreenState();
}

class _RegisterVehicleScreenState extends ConsumerState<RegisterVehicleScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  int _selectedVehicleType = 1;

  @override
  void initState() {
    super.initState();
    // Load vehicle types when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vehicleRegistrationProvider.notifier).loadVehicleTypes();
    });
  }

  void _onVehicleTypeSelected(int typeId) {
    setState(() {
      _selectedVehicleType = typeId;
    });
  }

  void _onPlateChanged(String? value) async {
    if (value != null) {
      final cleanPlate = value.replaceAll(RegExp(r'[^A-Z0-9]'), '');
      
      // Check if plate has valid length for either format
      if (cleanPlate.length == 7 || cleanPlate.length == 8) {
        // Get model by plate
        await ref.read(vehicleRegistrationProvider.notifier).getModelByPlate(cleanPlate);
        
        // Check if model was found and fill the field
        final modelResponse = ref.read(vehicleModelResponseProvider);
        if (modelResponse?.model != null) {
          _formKey.currentState?.fields['model']?.didChange(modelResponse!.model!);
        }
      }
    }
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
      
      final vehicle = VehicleRegistration(
        licensePlate: licensePlate,
        model: formData['model'] as String,
        type: _selectedVehicleType,
      );

      final success = await ref.read(vehicleRegistrationProvider.notifier).registerVehicle(vehicle);
      
      if (success) {
        Fluttertoast.showToast(
          msg: 'Veículo cadastrado com sucesso!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        
        // Refresh vehicle list
        ref.read(vehicleProvider.notifier).loadVehicles();
        
        // Reset form and go back
        _formKey.currentState?.reset();
        Navigator.of(context).pop();
      } else {
        final error = ref.read(vehicleRegistrationErrorProvider);
        Fluttertoast.showToast(
          msg: error ?? 'Erro ao cadastrar veículo',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleTypes = ref.watch(vehicleTypesProvider);
    final isLoading = ref.watch(vehicleRegistrationLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Cadastrar Veículo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
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
                      
                      if (vehicleTypes.isEmpty && !isLoading)
                        const Center(
                          child: Text('Nenhum tipo de veículo disponível'),
                        )
                      else if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: vehicleTypes.map((type) {
                            final isSelected = _selectedVehicleType == type.id;
                            return GestureDetector(
                              onTap: () => _onVehicleTypeSelected(type.id),
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
                                      type.icon,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      type.name,
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

              // License Plate Field
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'licensePlate',
                        decoration: InputDecoration(
                          labelText: 'Placa do veículo',
                          hintText: 'ABC-1234 ou ABC-1D23',
                          prefixIcon: const Icon(Icons.directions_car),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          helperText: 'Formato antigo: ABC-1234 | Mercosul: ABC-1D23',
                        ),
                        inputFormatters: [AppFormatters.universalPlateFormatter],
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
                      
                      FormBuilderTextField(
                        name: 'model',
                        decoration: InputDecoration(
                          labelText: 'Modelo do veículo',
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
                  onPressed: isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Cadastrar Veículo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Info card
              Card(
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'O modelo do veículo será preenchido automaticamente quando você inserir a placa.',
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
}

