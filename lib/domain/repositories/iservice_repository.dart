
import 'package:ninerapp/domain/entities/service.dart';

abstract class IServiceRepository {
  Future<Service> getServiceById(int id);
  Future<List<Service>> getServicesByBabysitterId(int id, bool isFinished);
  Future<List<Service>> getServicesByParentId(int id, bool isFinished);
  Future<void> addService(Service service);
  Future<void> updateServiceStatus(int id, String status);
  Future<void> deleteService(int id);
}