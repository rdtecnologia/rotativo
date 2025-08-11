import 'package:dio/dio.dart';
import '../models/vehicle_registration_models.dart';
import '../config/environment.dart';
import 'auth_service.dart';

class VehicleRegistrationService {
  static Dio? _dio;

  static Future<Dio> _getDio() async {
    if (_dio != null) return _dio!;

    final baseUrl = Environment.registerApi;
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept-Version': '1.0.0',
        'Content-Type': 'application/json',
      },
    ));

    // Add auth interceptor
    _dio!.interceptors.add(await AuthService.createAuthInterceptor());

    return _dio!;
  }



  /// Get vehicle model by license plate
  static Future<GetModelVehicleResponse> getModelByPlate(String licensePlate) async {
    try {
      final dio = await _getDio();
      final response = await dio.get('/driver/vehicle/model/$licensePlate');

      return GetModelVehicleResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return GetModelVehicleResponse(
          success: false,
          message: 'Modelo não encontrado para esta placa',
        );
      }
      throw Exception('Erro ao buscar modelo do veículo: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao buscar modelo: $e');
    }
  }

  /// Register a new vehicle
  static Future<bool> registerVehicle(VehicleRegistration vehicle) async {
    try {
      final dio = await _getDio();
      await dio.post('/driver/vehicle', data: vehicle.toJson());

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Este veículo já está cadastrado');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Dados inválidos para cadastro do veículo');
      }
      throw Exception('Erro ao cadastrar veículo: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao cadastrar veículo: $e');
    }
  }

  /// Get vehicle types (mock data based on React app)
  static Future<List<VehicleType>> getVehicleTypes() async {
    // Based on the React app, these are the common vehicle types
    // In a real implementation, this would come from an API
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    
    return [
      VehicleType(id: 1, name: 'Carro', icon: '🚗'),
      VehicleType(id: 2, name: 'Moto', icon: '🏍️'),
      VehicleType(id: 3, name: 'Caminhão', icon: '🚛'),
      VehicleType(id: 4, name: 'Ônibus', icon: '🚌'),
    ];
  }
}