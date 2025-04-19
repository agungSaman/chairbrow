
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

  Future<void> deleteFacility(String facilityId) async {
    await supabase.from('Facilities').delete().eq('id', facilityId);
  }
}