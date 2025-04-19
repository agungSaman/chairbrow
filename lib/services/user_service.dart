import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService{
  final SupabaseClient supabase;
  UserService(this.supabase);

  User? user;
  SharedPreferences? sharedPreferences;

  Future<Map<String, dynamic>> getUserProfile() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final userID = sharedPreferences?.getString("user_id");
    if (userID != null) {
      print('Authenticated user UID: $userID');
    } else {
      print('User is not authenticated!');
    }

    final response = await supabase
        .from('Customers')
        .select('*')
        .eq('user_id', userID??"")
        .single();

    return response;
  }

  Future<void> updateUserProfile(String name, String phone, String email) async {
    final userID = user?.id;
    if (userID != null) {
      print('Authenticated user UID: $userID');
    } else {
      print('User is not authenticated!');
    }

    await supabase.from('Customers').update({
      'name': name,
      'phone': phone,
      'email': email,
    }).eq('user_id', userID??"");
  }
}