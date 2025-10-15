
import 'package:ninerapp/domain/entities/parent.dart';

abstract class IParentRepository {
  Future<Parent> getParentById(int id);
  Future<Parent?> getParentByEmail(String email);
  Future<Parent?> getParentByEmailAndPassword(String email, String password);
  Future<int> addParent(Parent parent);
  Future<void> updateParent(Parent parent);
  Future<void> deleteParent(int id);
}