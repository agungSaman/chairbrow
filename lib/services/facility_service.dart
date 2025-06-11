
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FacilityService with ChangeNotifier {
  final SupabaseClient supabase;

  FacilityService(this.supabase);

  List<Map<String, dynamic>> _facilities = [];

  List<Map<String, dynamic>> get facilities => _facilities;

  Future<void> fetchFacilities(FacilityService facilityService) async {
    _facilities = await facilityService.getAllFacilities();
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getAllFacilities() async {
    final response = await supabase.from('Facilities').select('*');
    return response;
  }

  Future<void> addFacility(String name, String desc, String image) async {
    await supabase.from('Facilities').insert({
      'facility_name': name,
      'availability': true,
      'condition': desc,
      'image': image,
    });
  }

  Future<String> uploadImage(String path, File imageFile) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final userId = sharedPreferences.getString("user_id");

      if (userId == null) {
        throw Exception('User ID not found.');
      }

      final String fullPath = await supabase.storage.from('avatars').upload(
        path,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      print('File uploaded successfully: $fullPath');
      return fullPath;
    } catch (e) {
      print('Error uploading image: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> deleteFacility(String facilityId) async {
    try {
      print('Deleting bookings for facility ID: $facilityId');
      await supabase.from('Bookings').delete().match({'facility_id': facilityId});

      print('Deleting facility with ID: $facilityId');
      await supabase.from('Facilities').delete().match({'id': facilityId});

      print('Facility and related bookings deleted successfully.');
      getAllFacilities();
    } catch (e) {
      print('Error deleting facility: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> updateFacility(String facilityId, bool availability) {
    return supabase.from('Facilities').update({
      'availability': availability,
    }).match({'id': facilityId});
  }
}