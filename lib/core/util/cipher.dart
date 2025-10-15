import 'dart:convert';
import 'package:crypto/crypto.dart';

class Cipher {
  // Se devuelve la contraseña que se pase pero cifrada en sha256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}