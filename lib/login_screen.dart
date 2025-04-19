import 'package:chairbrow/dashboard_screen.dart';
import 'package:chairbrow/register_screen.dart';
import 'package:chairbrow/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService authService = AuthService(SupabaseClient(AppConstant.EXPO_PUBLIC_SUPABASE_URL, AppConstant.EXPO_PUBLIC_SUPABASE_ANON_KEY));

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await authService.login(emailController.text, passwordController.text);
                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login Successful!')),
                  );
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => DashboardScreen()), (root) => false);
                }
              },
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => RegisterScreen()), (root) => false);
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}