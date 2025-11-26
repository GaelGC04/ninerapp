
import 'package:ninerapp/domain/entities/person.dart';
import 'package:ninerapp/domain/entities/service.dart';

abstract class IServiceRepository {
  Future<Service> getServiceById(int id);
  Future<List<Service>> getServicesByBabysitterId(int id, bool isFinished, String? paymentMethod, DateTime? initialDate, DateTime? finalDate, String? statusService);
  Future<List<Service>> getServicesByParentId(int id, bool isFinished, String? paymentMethod, DateTime? initialDate, DateTime? finalDate, String? statusService);
  Future<void> addService(Service service);
  Future<void> updateServiceStatus(int id, String status);
  Future<void> deleteService(int id, Person person);
  Future<bool> updateUserRate(Service service, bool isRatedByParent, int starsAmount);
  Future<bool> updateUserReports(Service service, bool isReportedByParent);
}