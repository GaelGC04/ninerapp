import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ninerapp/domain/repositories/ibabysitter_repository.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';

class BabysitterRepository implements IBabysitterRepository {
  final SupabaseClient _supabase;

  BabysitterRepository({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<List<Babysitter>> getBabysitters(int minimumStars, int minDistanceMts, int maxDistanceMts, int minExpYears, int maxExpYears, int minPricePerHour, int maxPricePerHour, bool hasPhysicalDisabilityExp, bool hasVisualDisabilityExp, bool hasHearingDisabilityExp) async {
    try {
      var response = await _supabase
        .from('babysitter')
        .select('*')
        .order('name', ascending: true);

      final List<Babysitter> babysitters = (response as List)
        .map((babysitter) {
          return Babysitter.fromMap({
            ...babysitter,
          });
        }).toList();

      return babysitters;
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener niñeros: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener los niñeros: $e');
    }
  }

  @override
  Future<Babysitter> getBabysitterById(int id) async {
    try {
      var response = await _supabase
        .from('babysitter')
        .select('*')
        .eq('id', id)
        .maybeSingle();

      return Babysitter.fromMap(response!);
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener niñero: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener el niñero: $e');
    }
  }
  
  @override
  Future<int> addBabysitter(Babysitter babysitter) async {
    try {
      final response = await _supabase
        .from('babysitter')
        .insert(babysitter.toMap())
        .select('id');
      return response.first['id'] as int;

    } on PostgrestException catch (e) {
      throw Exception('Error al agregar niñero: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al agregar niñero: $e');
    }
  }
  
  @override
  Future<void> deleteBabysitter(int id) async {
    try {
      return await _supabase.from('babysitter').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar niñero: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al eliminar niñero: $e');
    }
  }
  
  @override
  Future<Babysitter?> getBabysitterByEmail(String email) async {
    try {
      var response = await _supabase
        .from('babysitter')
        .select('*')
        .eq('email', email)
        .maybeSingle();

      if (response == null) {
        return null;
      }

      return Babysitter.fromMap(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener niñero: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener a niñero: $e');
    }
  }
  
  @override
  Future<void> updateBabysitter(Babysitter babysitter) async {
    try {
      return await _supabase
        .from('babysitter')
        .update(babysitter.toMap())
        .eq('id', babysitter.id!);
    } on PostgrestException catch (e) {
      throw Exception('Error al actualizar niñero: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al actualizar niñero: $e');
    }
  }
  
  @override
  Future<Babysitter?> getBabysitterByEmailAndPassword(String email, String password) async {
    try {
      var response = await _supabase
        .from('babysitter')
        .select('*')
        .eq('email', email)
        .eq('password', password)
        .maybeSingle();

      if (response == null) {
        return null;
      }

      return Babysitter.fromMap(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener niñero: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener a niñero: $e');
    }
  }
}