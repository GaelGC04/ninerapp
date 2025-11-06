
import 'package:ninerapp/domain/entities/service.dart';

abstract class IChatRepository {
  Future<Map<int, String>> getMessages(Service service, bool getParentMessages);
  Future<int> postMessage(Service service, String message, bool isFromParent);
}
