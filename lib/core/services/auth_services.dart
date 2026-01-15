import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Asegúrate que la llave sea la misma con la que guardaste el token al hacer Login
    return prefs.getString('token');
  }
}
