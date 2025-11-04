import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ninerapp/core/util/location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ninerapp/domain/repositories/ibabysitter_repository.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';

class BabysitterRepository implements IBabysitterRepository {
  final SupabaseClient _supabase;

  BabysitterRepository({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<List<Babysitter>> getBabysitters(int minimumStars, int minDistanceMts, int maxDistanceMts, int minExpYears, int maxExpYears, int minPricePerHour, int maxPricePerHour, bool hasPhysicalDisabilityExp, bool hasVisualDisabilityExp, bool hasHearingDisabilityExp, double? lastLatitude, double? lastLongitude) async {
    try {
      var query = _supabase.from('babysitter').select('*'); 

      // Filtro de costos por hora
      if (minPricePerHour > 0) {
        query = query.gte('price_per_hour', minPricePerHour);
      }
      if (maxPricePerHour < 10000) {
        query = query.lte('price_per_hour', maxPricePerHour);
      }

      // Se ejecuta la consulta
      final response = await query.order('name', ascending: true);

      // Calcular experiencia en años
      final List<Babysitter> allBabysitters = (response as List)
        .map((babysitterMap) => Babysitter.fromMap(babysitterMap))
        .toList();

      List<Babysitter> filteredList = allBabysitters;

      if (minimumStars > 0) {
        filteredList = filteredList.where((babysitter) {
          return babysitter.getAverageStars() >= minimumStars; 
        }).toList();
      }

      final bool filterByDistanceEnabled = lastLatitude != null && lastLongitude != null;
      // Filtros de rango de años de experiencia
      filteredList = filteredList.where((babysitter) {
        final actualYears = babysitter.getExperienceYears();
        bool passesMinExp = minExpYears == 0 || actualYears >= minExpYears;
        bool passesMaxExp = maxExpYears == 100 || actualYears <= maxExpYears;

        // Filtro de Distancia
        if (filterByDistanceEnabled == true) {
          if (babysitter.lastLatitude == null || babysitter.lastLongitude == null) {
            babysitter.distanceMeters = null;
            return passesMinExp && passesMaxExp;
          }

          // Se calcula y asigna la distancia de cada niñero
          final distanceMeters = LocationService.getDistanceInMeters(LatLng(lastLatitude!, lastLongitude!), LatLng(babysitter.lastLatitude!, babysitter.lastLongitude!));
          babysitter.distanceMeters = distanceMeters;

          // Aplicar el filtro de rango de distancia
          bool passesMinDist = distanceMeters >= minDistanceMts;
          bool passesMaxDist = distanceMeters <= maxDistanceMts;

          return passesMinExp && passesMaxExp && passesMinDist && passesMaxDist;
        }
        
        // Si la ubicación del usuario es desconocida, solo se aplica el filtro de experiencia
        return passesMinExp && passesMaxExp;
      }).toList();

      // Filtros de discapacidades
      final bool filterByDisability = hasPhysicalDisabilityExp || hasVisualDisabilityExp || hasHearingDisabilityExp;

      if (filterByDisability == true) {
        filteredList = filteredList.where((babysitter) {
          bool passesPhysical = !hasPhysicalDisabilityExp || babysitter.expPhysicalDisability == true;
          bool passesVisual = !hasVisualDisabilityExp || babysitter.expVisualDisability == true;
          bool passesHearing = !hasHearingDisabilityExp || babysitter.expHearingDisability == true;
          
          return passesPhysical && passesVisual && passesHearing;
        }).toList();
      }

      if (filterByDistanceEnabled) {
        filteredList.sort((a, b) {
          // Si la distancia es nula (un niñero sin ubicación), se envía al final de la lista
          final distanceA = a.distanceMeters ?? 999999999;
          final distanceB = b.distanceMeters ?? 999999999;
          return distanceA.compareTo(distanceB);
        });
      }

      // Se ordena por las distancias respecto al usuario
      return filteredList;
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