import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to access Health AI',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.write(
      key: 'biometric_$email',
      value: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
  }

  Future<Map<String, String>?> getCredentials(String email) async {
    final stored = await _secureStorage.read(key: 'biometric_$email');
    if (stored != null) {
      final data = jsonDecode(stored);
      return {
        'email': data['email'],
        'password': data['password'],
      };
    }
    return null;
  }

  Future<bool> hasCredentials(String email) async {
    final stored = await _secureStorage.read(key: 'biometric_$email');
    return stored != null;
  }

  Future<void> removeCredentials(String email) async {
    await _secureStorage.delete(key: 'biometric_$email');
  }
}