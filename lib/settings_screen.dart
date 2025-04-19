import 'package:chairbrow/splash_screen.dart';
import 'package:chairbrow/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService authService = AuthService(
      SupabaseClient(
          AppConstant.EXPO_PUBLIC_SUPABASE_URL,
          AppConstant.EXPO_PUBLIC_SUPABASE_ANON_KEY,
          authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.implicit,
          ),
          realtimeClientOptions: const RealtimeClientOptions(
            logLevel: RealtimeLogLevel.info,
          ),
          storageOptions: const StorageClientOptions(
            retryAttempts: 10,
          ),
          postgrestOptions: PostgrestClientOptions(
            schema: 'public',
          )
      )
  );

  final UserService userService = UserService(
      SupabaseClient(
          AppConstant.EXPO_PUBLIC_SUPABASE_URL,
          AppConstant.EXPO_PUBLIC_SUPABASE_ANON_KEY,
          authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.implicit,
          ),
          realtimeClientOptions: const RealtimeClientOptions(
            logLevel: RealtimeLogLevel.info,
          ),
          storageOptions: const StorageClientOptions(
            retryAttempts: 10,
          ),
          postgrestOptions: PostgrestClientOptions(
            schema: 'public',
          )
      )
  );

  // Controllers untuk input form
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Memuat data pengguna saat halaman dimuat
  }

  // Memuat data pengguna dari Supabase
  Future<void> _loadUserData() async {
    userService.user = authService.user;
    final userData = await userService.getUserProfile();
    setState(() {
      nameController.text = userData['name'];
      phoneController.text = userData['phone'] ?? '';
      emailController.text = userData['email'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Perbarui data pengguna di Supabase
                await userService.updateUserProfile(
                  nameController.text,
                  phoneController.text,
                  emailController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile Updated Successfully!')),
                );
              },
              child: Text('Save Changes'),
            ),
            SizedBox(height: 24),
            Text(
              'Change Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Ubah password pengguna melalui Supabase Auth
                await authService.changePassword(passwordController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password Changed Successfully!')),
                );
              },
              child: Text('Change Password'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Logout pengguna
                await authService.logout();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                    builder: (context) => SplashScreen()
                ), (root) => false); // Kembali ke halaman login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Warna tombol merah
              ),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}