import 'package:ninerapp/domain/entities/service.dart';
import 'package:ninerapp/domain/repositories/ichat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepository implements IChatRepository {
  final SupabaseClient _supabase;

  ChatRepository({required SupabaseClient supabase}) : _supabase = supabase;
  
  @override
  Future<Map<int, String>> getMessages(Service service, bool getParentMessages) async {
    try {
      final response = await _supabase
        .from('service_chat')
        .select('*')
        .eq('service_id', service.id!)
        .eq('is_from_parent', getParentMessages)
        .order('id', ascending: true);

      Map<int, String> messages = {};
      for (var message in response) {
        messages[message["id"] as int] = (message["text"].toString());
      }

      return messages;
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener hijos: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener las hijos: $e');
    }
  }
  
  @override
  Future<int> postMessage(Service service, String message, bool isFromParent) async {
    try {
      final response = await _supabase
        .from('service_chat')
        .insert({
          'parent_id': service.parent.id!,
          'babysitter_id': service.babysitter.id!,
          'service_id': service.id!,
          'text': message,
          'is_from_parent': isFromParent,
        })
        .select('id');

      if (response.isNotEmpty) {
        return response.first['id'] as int;
      }

      throw Exception('Error inesperado al agregar mensaje: No se pudo obtener el ID del mensaje.');
    } on PostgrestException catch (e) {
      throw Exception('Error al agregar mensaje: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al agregar mensaje: $e');
    }
  }
}