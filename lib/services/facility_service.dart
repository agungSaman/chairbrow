
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FacilityService {
  final SupabaseClient supabase;

  FacilityService(this.supabase);

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
    await supabase.from('Facilities').delete().eq('id', facilityId);
  }
}