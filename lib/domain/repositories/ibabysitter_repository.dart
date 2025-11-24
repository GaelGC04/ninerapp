
import 'package:ninerapp/domain/entities/babysitter.dart';

abstract class IBabysitterRepository {
  Future<List<Babysitter>> getFavoriteBabysitters(double? lastLatitude, double? lastLongitude, int parentId);
  Future<List<Babysitter>> getBabysitters(int minimumStars, int minDistanceMts, int maxDistanceMts, int minExpYears, int maxExpYears, int minPricePerHour, int maxPricePerHour, bool hasPhysicalDisabilityExp, bool hasVisualDisabilityExp, bool hasHearingDisabilityExp, double? lastLatitude, double? lastLongitude, int parentId);
  Future<Babysitter> getBabysitterById(int id);
  Future<Babysitter?> getBabysitterByEmail(String email);
  Future<Babysitter?> getBabysitterByEmailAndPassword(String email, String password);
  Future<int> addBabysitter(Babysitter babysitter);
  Future<void> editBabysitterFavorite(int babysitterId, int parentId, bool isFavorite);
  Future<void> updateBabysitter(Babysitter babysitter);
  Future<void> deleteBabysitter(int id);
  Future<bool> updateBabysitterDocuments(Babysitter babysitter, String documentType);
}