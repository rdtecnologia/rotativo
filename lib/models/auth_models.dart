// Models for authentication
import '../utils/date_utils.dart' as AppDateUtils;

class User {
  final String? id;
  final String? name;
  final String? email;
  final String? cpf;
  final String? phone;
  final String? token;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    this.id,
    this.name,
    this.email,
    this.cpf,
    this.phone,
    this.token,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      cpf: json['cpf']?.toString(),
      phone: json['mobile']?.toString(),
      token: json['token']?.toString(),
      createdAt: json['createdAt'] != null
          ? AppDateUtils.DateUtils.parseUtcDate(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? AppDateUtils.DateUtils.parseUtcDate(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'cpf': cpf,
      'mobile': phone,
      'token': token,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? cpf,
    String? phone,
    String? token,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      phone: phone ?? this.phone,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAuthenticated => token != null && token!.isNotEmpty;
}

class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class CheckCPFResponse {
  final String action; // 'login' or 'register'
  final String? message;

  const CheckCPFResponse({
    required this.action,
    this.message,
  });

  factory CheckCPFResponse.fromJson(Map<String, dynamic> json) {
    return CheckCPFResponse(
      action: json['action'] ?? '',
      message: json['message']?.toString(),
    );
  }
}

class RegisterRequest {
  final String cpf;
  final String fullname;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;

  const RegisterRequest({
    required this.cpf,
    required this.fullname,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': fullname,
      'email': email,
      'password': password,
      'mobile': phone.replaceAll(RegExp(r'[^\d]'), ''), // Remove mask
      'cpf': cpf.replaceAll(RegExp(r'[^\d]'), ''), // Remove mask
    };
  }
}

class ForgotPasswordResponse {
  final String? message;
  final String? email;
  final bool success;

  const ForgotPasswordResponse({
    this.message,
    this.email,
    required this.success,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      message: json['message']?.toString(),
      email: json['email']?.toString(),
      success: json['success'] ?? false,
    );
  }
}

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final CheckCPFResponse? checkCPF;
  final bool biometricEnabled;
  final bool biometricAvailable;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.checkCPF,
    this.biometricEnabled = false,
    this.biometricAvailable = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    CheckCPFResponse? checkCPF,
    bool? biometricEnabled,
    bool? biometricAvailable,
    bool clearUser = false,
    bool clearError = false,
    bool clearCheckCPF = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      checkCPF: clearCheckCPF ? null : (checkCPF ?? this.checkCPF),
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
    );
  }

  bool get isAuthenticated => user?.isAuthenticated ?? false;
}
