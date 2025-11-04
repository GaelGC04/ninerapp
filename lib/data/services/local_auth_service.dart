import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/domain/entities/person.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static const String _userIdKey = 'user_id';
  // Si es 'parent' o 'babysitter'
  static const String _userTypeKey = 'user_type';

  // Se guarda la información del usuario en la BD local
  Future<void> saveUserSession(Person user) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt(_userIdKey, user.id!);
    
    if (user is Parent) {
      await prefs.setString(_userTypeKey, 'parent');
    } else if (user is Babysitter) {
      await prefs.setString(_userTypeKey, 'babysitter');
    }
  }

  // Aqui se carga la información de la sesión si existe
  Future<Map<String, dynamic>?> loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);
    final userType = prefs.getString(_userTypeKey);

    if (userId != null && userType != null) {
      return {
        'id': userId,
        'type': userType,
      };
    }
    return null;
  }

  // Cierra la sesión borrando los datos
  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userTypeKey);
  }
}
