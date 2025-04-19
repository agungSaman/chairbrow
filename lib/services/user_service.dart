import 'package:supabase/supabase.dart';

class UserService{
  final SupabaseClient supabase;

  UserService(this.supabase);

  Future<Map<String, dynamic>> getUserProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    final response = await supabase
        .from('users')
        .select('*')
        .eq('id', userId)
        .single();

    return response;
  }

  Future<void> updateUserProfile(String name, String phone, String email) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    await supabase.from('users').update({
      'name': name,
      'phone': phone,
      'email': email,
    }).eq('id', userId);
  }
}