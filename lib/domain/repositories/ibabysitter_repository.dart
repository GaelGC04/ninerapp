
import 'package:ninerapp/domain/entities/babysitter.dart';

abstract class IBabysitterRepository {
  Future<List<Babysitter>> getBabysitters(int minimumStars, int minDistanceMts, int maxDistanceMts, int minExpYears, int maxExpYears, int minPricePerHour, int maxPricePerHour, bool hasPhysicalDisabilityExp, bool hasVisualDisabilityExp, bool hasHearingDisabilityExp);
  Future<Babysitter> getBabysitterById(int id);
  Future<Babysitter?> getBabysitterByEmail(String email);
  Future<Babysitter?> getBabysitterByEmailAndPassword(String email, String password);
  Future<int> addBabysitter(Babysitter babysitter);
  Future<void> updateBabysitter(Babysitter babysitter);
  Future<void> deleteBabysitter(int id);
}