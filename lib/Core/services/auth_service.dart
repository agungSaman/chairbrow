import 'dart:developer';

import 'package:flutter/cupertino.dart'; // Often not needed unless using Cupertino-specific widgets
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart'; // This is the core Supabase client
import 'package:supabase_flutter/supabase_flutter.dart'; // Provides Supabase.instance.client etc.

class AuthService {
  final SupabaseClient supabase;

  AuthService(this.supabase);

  User? user;
  Session? session;
  SharedPreferences? sharedPreferences;

  Future<void> register(String email, String password, String name, String phone, String birthDate) async {
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

  Future<bool> login(String email, String password) async {
    sharedPreferences = await SharedPreferences.getInstance();
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(email: email, password: password);
      // It's good practice to check response.user or response.session here too
      // although signInWithPassword usually throws an AuthException on failure.
      if (response.user != null) {
        log("Login successful for user: ${response.user}");
        session = response.session;
        user = response.user;
        sharedPreferences?.setString("user_id", user!.id);
        return true;
      } else {
        // This case should ideally be covered by the catch block, but as a fallback:
        debugPrint("Login failed: User object is null after signInWithPassword.");
        return false;
      }
    } on AuthException catch (e) {
      debugPrint('AuthException during login: ${e.message}');
      // You might want to throw here to let the UI handle the specific error.
      // throw Exception('Login failed: ${e.message}');
      return false; // Return false or re-throw
    } catch (e) {
      debugPrint('An unexpected error occurred during login: $e');
      // throw Exception('An unexpected error occurred: $e');
      return false; // Return false or re-throw
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User is not logged in.');
      }

      // updateUser returns an AuthResponse
      final UserResponse response = await supabase.auth.updateUser(UserAttributes(password: newPassword));

      if (response.user == null) {
        throw Exception('Failed to update password: User object is null in response.');
      }
      debugPrint('Password changed successfully for user: ${response.user!.email}');

    } on AuthException catch (e) {
      debugPrint('AuthException during password change: ${e.message}');
      throw Exception('Failed to change password: ${e.message}');
    } catch (e) {
      debugPrint('An unexpected error occurred during password change: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<bool> checkUserLogin() async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
      final userID = sharedPreferences?.getString("user_id");
      if (userID != "") {
        debugPrint('User is already logged in: $userID');
        return true;
      } else {
        debugPrint('User is not logged in.');
        return false;
      }
    } on AuthException catch (e) {
      debugPrint('AuthException during checkUserLogin: ${e.message}');
      return false;
      // throw Exception('Failed to check user login status: ${e.message}');
    }
  }

  Future<void> logout() async {
    sharedPreferences = await SharedPreferences.getInstance();
    try {
      await sharedPreferences?.setString("user_id", "");
      await supabase.auth.signOut();
      debugPrint('User logged out successfully.');
    } on AuthException catch (e) {
      debugPrint('AuthException during logout: ${e.message}');
      throw Exception('Logout failed: ${e.message}');
    } catch (e) {
      debugPrint('An unexpected error occurred during logout: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}