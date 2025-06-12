import 'package:flutter/cupertino.dart';
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

  Future<void> addNewCustomers(String email, String password, String name, String phone, String birthDate) async {
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      debugPrint("AuthResponse from signUp: ${response.user}"); // Use debugPrint for Flutter
      debugPrint("AuthSession from signUp: ${response.session}");

      // Check for errors in the signUp response first
      if (response.user == null) {
        String errorMessage = 'Registration failed.';
        if (response.session?.isExpired ?? false) {
          errorMessage = 'Session expired during registration.';
        }
        if (response.session?.refreshToken == null && response.user == null) {
          errorMessage = 'Sign up failed, no user or session returned.';
        }
        throw Exception(errorMessage);
      }

      user = supabase.auth.currentUser;
      if (user != null) {
        print('Authenticated user UID: ${user?.id}');
      } else {
        print('User is not authenticated!');
      }

      // If signUp was successful and a user was returned, proceed to insert into 'Users' table
      await supabase.from('Customers').insert({
        'user_id': user?.id, // CRITICAL: This 'id' must match auth.uid() for RLS
        'name': name,
        'email': email,
        'phone': phone,
        'user_role': "users",
        'birth_date': birthDate,
        'created_at': response.user!.createdAt, // Ensure this is a string
      }).select();

      debugPrint("User profile successfully created in 'Users' table.");

    } on AuthException catch (e) {
      // Catch Supabase specific authentication errors
      debugPrint('AuthException during registration: ${e.message}');
      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      // Catch any other unexpected errors
      debugPrint('An unexpected error occurred during registration: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> updateUserProfile(String name, String phone, String email, String birthDate) async {
    sharedPreferences = await SharedPreferences.getInstance();
    final userIDs = sharedPreferences?.getString("user_id");
    if (userIDs != null) {
      print('Authenticated user UID: $userIDs');
    } else {
      print('User is not authenticated!');
    }

    await supabase.from('Customers').update({
      'name': name,
      'phone': phone,
      'email': email,
      'birth_date': birthDate,
    }).eq('user_id', userIDs??"");
  }
}