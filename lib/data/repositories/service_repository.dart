import 'package:flutter/material.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/domain/entities/child.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/domain/entities/person.dart';
import 'package:ninerapp/domain/entities/service.dart';
import 'package:ninerapp/domain/entities/service_status.dart';
import 'package:ninerapp/domain/repositories/iservice_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceRepository implements IServiceRepository {
  final SupabaseClient _supabase;

  ServiceRepository({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<bool> updateUserRate(Service service, bool isRatedByParent, int starsAmount) async {
    try {
      if (isRatedByParent == true) {
        Map<String, dynamic> jsonBabysitter = service.babysitter.toMap();
        jsonBabysitter['rating'] += starsAmount;
        jsonBabysitter['amount_ratings'] += 1;

        await _supabase
          .from('babysitter')
          .update({
            'rating': jsonBabysitter['rating'],
            'amount_ratings': jsonBabysitter['amount_ratings'],
          }).eq('id', service.babysitter.id!).then((_) async {
            await _supabase
              .from('service')
              .update({
                'rated_by_parent': true,
              }).eq('id', service.id!);
          });
      } else {
        Map<String, dynamic> jsonParent = service.parent.toMap();
        jsonParent['rating'] += starsAmount;
        jsonParent['amount_ratings'] += 1;

        await _supabase
          .from('parent')
          .update({
            'rating': jsonParent['rating'],
            'amount_ratings': jsonParent['amount_ratings'],
          }).eq('id', service.parent.id!).then((_) async {
            await _supabase
              .from('service')
              .update({
                'rated_by_babysitter': true,
              }).eq('id', service.id!);
          });
      }
      return true;
    } on PostgrestException catch (e) {
      debugPrint('Error al calificar al usuario: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error inesperado al calificar al usuario: $e');
      return false;
    }
  }

  @override
  Future<bool> updateUserReports(Service service, bool isReportedByParent) async {
    try {
      if (isReportedByParent == true) {
        Map<String, dynamic> jsonBabysitter = service.babysitter.toMap();
        jsonBabysitter['amount_reports'] += 1;

        await _supabase
          .from('babysitter')
          .update({
            'amount_reports': jsonBabysitter['amount_reports'],
          }).eq('id', service.babysitter.id!).then((_) async {
            await _supabase
              .from('service')
              .update({
                'reported_by_parent': true,
              }).eq('id', service.id!);
          });
      } else {
        Map<String, dynamic> jsonParent = service.parent.toMap();
        jsonParent['amount_reports'] += 1;

        await _supabase
          .from('parent')
          .update({
            'amount_reports': jsonParent['amount_reports'],
          }).eq('id', service.parent.id!).then((_) async {
            await _supabase
              .from('service')
              .update({
                'reported_by_babysitter': true,
              }).eq('id', service.id!);
          });
      }
      return true;
    } on PostgrestException catch (e) {
      debugPrint('Error al reportar al usuario: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error inesperado al reportar al usuario: $e');
      return false;
    }
  }

  @override
  Future<void> addService(Service service) async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
        .from('service')
        .insert(service.toMap())
        .select('id'); // asi se obtiene el id que le asignó la bd

      final int serviceId = response.first['id'] as int;

      for (var child in service.children) {
        await _supabase.from('service_children').insert({
          'service_id': serviceId,
          'child_id': child.id,
        });
      }
    } on PostgrestException catch (e) {
      throw Exception('Error al agregar servicio: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al agregar servicio: $e');
    }
  }

  @override
  Future<void> deleteService(int id, Person person) async {
    try {
      final response = await _supabase
        .from('service')
        .select('*, babysitter:babysitter(*), parent:parent(*)')
        .eq('id', id)
        .maybeSingle();

      final Service service = Service.fromMap({
        ...?response,
        'babysitter': response!['babysitter'],
        'parent': response['parent']
      }, []);

      if (person is Parent) {
        if (service.deletedByBabysitter == false) {
          await _supabase
            .from('service')
            .update({'deleted_by_babysitter': true})
            .eq('id', id);
          return;
        }
      } else if (person is Babysitter) {
        if (service.deletedByParent == false) {
          await _supabase
            .from('service')
            .update({'deleted_by_parent': true})
            .eq('id', id);
          return;
        }
      }

      return await _supabase.from('service').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar servicio: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al eliminar servicio: $e');
    }
  }

  @override
  Future<Service> getServiceById(int id) async {
    try {
      final response = await _supabase
        .from('service')
        .select('*, babysitter:babysitter(*), parent:parent(*)')
        .eq('id', id)
        .maybeSingle();

      final childrenResponse = await _supabase
        .from('service_children')
        .select('child:child(*)')
        .eq('service_id', id);

      List<Child> children = (childrenResponse as List)
        .map((child) => Child.fromMap(child['child'] as Map<String, dynamic>))
        .toList();

      final Service service = Service.fromMap({
        ...?response,
        'babysitter': response!['babysitter'],
        'parent': response['parent']
      }, children = children);

      return service;
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener el servicio: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener el servicio: $e');
    }
  }

  @override
  Future<List<Service>> getServicesByBabysitterId(int id, bool isFinished, bool paymentMethodIsCard, bool paymentMethodIsCash, DateTime? initialDate, DateTime? finalDate, String? statusService) async {
    try {
      final response = await _supabase
        .from('service')
        .select('*, babysitter:babysitter(*), parent:parent(*)')
        .eq('babysitter_id', id)
        .eq('deleted_by_babysitter', false)
        .order('date', ascending: true);

      final List<Service> services = (response as List)
        .map((service) {
          return Service.fromMap({
            ...service,
            'parent': service['parent'],
            'babysitter': service['babysitter'],
          }, []);
        }).toList();

        if (isFinished == true) {
          final filteredServices = services.where((service) =>
            service.status == ServiceStatus.completed.value ||
            service.status == ServiceStatus.rejected.value ||
            service.status == ServiceStatus.canceled.value).toList();
          return filteredServices;
        } else {
          final filteredServices = services.where((service) =>
            service.status != ServiceStatus.completed.value &&
            service.status != ServiceStatus.rejected.value &&
            service.status != ServiceStatus.canceled.value).toList();
          return filteredServices;
        }
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener servicios: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener los servicios: $e');
    }
  }

  @override
  Future<List<Service>> getServicesByParentId(int id, bool isFinished, bool paymentMethodIsCard, bool paymentMethodIsCash, DateTime? initialDate, DateTime? finalDate, String? statusService) async {
    try {
      final response = await _supabase
        .from('service')
        .select('*, babysitter:babysitter(*), parent:parent(*)')
        .eq('parent_id', id)
        .eq('deleted_by_parent', false)
        .order('date', ascending: true);

      final List<Service> services = (response as List)
        .map((service) {
          return Service.fromMap({
            ...service,
            'parent': service['parent'],
            'babysitter': service['babysitter'],
          }, []);
        }).toList();

        if (isFinished == true) {
          final filteredServices = services.where((service) =>
            service.status == ServiceStatus.completed.value ||
            service.status == ServiceStatus.rejected.value ||
            service.status == ServiceStatus.canceled.value).toList();
          return filteredServices;
        } else {
          final filteredServices = services.where((service) =>
            service.status != ServiceStatus.completed.value &&
            service.status != ServiceStatus.rejected.value &&
            service.status != ServiceStatus.canceled.value).toList();
          return filteredServices;
        }
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener servicios: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener los servicios: $e');
    }
  }
  
  @override
  Future<void> updateServiceStatus(int id, String status) async {
    try {
      return await _supabase
        .from('service')
        .update({'status': status})
        .eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Error al actualizar servicio: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al actualizar servicio: $e');
    }
  }
}