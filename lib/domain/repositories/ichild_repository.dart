import 'package:ninerapp/domain/entities/child.dart';

// "Contrato" del repositorio de Child
abstract class IChildRepository {
  Future<List<Child>> getChildrenByOrder(String order, int parentId);
  Future<void> addChild(Child child);
  Future<void> updateChild(Child child);
  Future<void> deleteChild(int id);
}