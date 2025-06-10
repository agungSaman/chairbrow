import 'package:flutter/cupertino.dart';

import '../services/facility_service.dart';

class FacilityProvider with ChangeNotifier {
  List<Map<String, dynamic>> _facilities = [];

  List<Map<String, dynamic>> get facilities => _facilities;

  Future<List<Map<String, dynamic>>> fetchFacilities(FacilityService facilityService) async {
    _facilities = await facilityService.getAllFacilities();
    return _facilities;
  }

  Future<void> addFacility(String name, String desc, String image, FacilityService facilityService) async {
    await facilityService.addFacility(name, desc, image);
    await fetchFacilities(facilityService);
    notifyListeners();
  }

  Future<void> deleteFacility(String facilityId, FacilityService facilityService) async {
    await facilityService.deleteFacility(facilityId);
    await fetchFacilities(facilityService);
    notifyListeners();
  }
}