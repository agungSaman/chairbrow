import 'package:flutter/cupertino.dart';
import 'package:supabase/supabase.dart';

class AuthService {
  final SupabaseClient supabase;

  AuthService(this.supabase);

  Future<void> register(String email, String password, String name, String phone) async {
    final response = await supabase.auth.signUp(email: email, phone: phone, password: password);
    if (response.user != null) {
      await supabase.from('users').insert({
        'id': response.user!.id,
        'name': name,
        'email': email,
      });
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(email: email, password: password);
      debugPrint("$response");
      return true;
    } catch (e) {
      debugPrint("$e");
      return false;
    }
  }

  Future<void> changePassword(String newPassword) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}