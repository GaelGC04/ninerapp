import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/domain/repositories/iparent_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ParentRepository implements IParentRepository {
  final SupabaseClient _supabase;

  ParentRepository({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Parent?> getParentByEmail(String email) async {
    try {
      var response = await _supabase
        .from('parent')
        .select('*')
        .eq('email', email)
        .maybeSingle();

      if (response == null) {
        return null;
      }

      return Parent.fromMap(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener madre/padre: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener a madre/padre: $e');
    }
  }

  @override
  Future<Parent> getParentById(int id) async {
    try {
      var response = await _supabase
        .from('parent')
        .select('*')
        .eq('id', id)
        .maybeSingle();

      return Parent.fromMap(response!);
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener madre/padre: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener a madre/padre: $e');
    }
  }

  @override
  Future<int> addParent(Parent parent) async {
    try {
      final response = await _supabase
        .from('parent')
        .insert(parent.toMap())
        .select('id');
      return response.first['id'] as int;

    } on PostgrestException catch (e) {
      throw Exception('Error al agregar madre/padre: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al agregar madre/padre: $e');
    }
  }
  
  @override
  Future<void> deleteParent(int id) async {
    try {
      return await _supabase.from('parent').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar madre/padre: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al eliminar madre/padre: $e');
    }
  }

  @override
  Future<void> updateParent(Parent parent) async {
    try {
      final Map<String, dynamic> dataToUpdate = parent.toMap();
      dataToUpdate.remove('password');
      dataToUpdate.remove('rating');
      dataToUpdate.remove('amount_ratings');

      return await _supabase
        .from('parent')
        .update(dataToUpdate)
        .eq('id', parent.id!);
    } on PostgrestException catch (e) {
      throw Exception('Error al actualizar madre/padre: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al actualizar madre/padre: $e');
    }
  }
  
  @override
  Future<Parent?> getParentByEmailAndPassword(String email, String password) async {
    try {
      var response = await _supabase
        .from('parent')
        .select('*')
        .eq('email', email)
        .eq('password', password)
        .maybeSingle();

      if (response == null) {
        return null;
      }

      return Parent.fromMap(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener madre/padre: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener a madre/padre: $e');
    }
  }
}