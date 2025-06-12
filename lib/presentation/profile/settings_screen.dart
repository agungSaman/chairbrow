import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Core/services/auth_service.dart';
import '../../Core/services/user_service.dart';
import '../../Core/utils/constant.dart';
import '../auth/splash_screen.dart';

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
  final TextEditingController birthdateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Memuat data pengguna dari Supabase
  Future<void> _loadUserData() async {
    userService.user = authService.user;
    final userData = await userService.getUserProfile();
    setState(() {
      nameController.text = userData['name'] ?? '';
      phoneController.text = userData['phone'] ?? '';
      emailController.text = userData['email'] ?? '';
      birthdateController.text = userData['birth_date'] ?? '';
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
        child: SingleChildScrollView(
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
              SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  var date = await showDatePicker(
                      context: context,
                      currentDate: DateTime.now(),
                      initialEntryMode: DatePickerEntryMode.calendar,
                      firstDate: DateTime(1900, 1, 1),
                      lastDate: DateTime(2125, 1, 1));

                  birthdateController.text = date?.toIso8601String()??"";
                  print("tanggal lahir ${birthdateController.text}");
                },
                child: TextField(
                  controller: birthdateController,
                  enabled: false,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    label: Text('Tanggal Lahir'),
                    labelStyle: TextStyle(color: Colors.black),
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black.withOpacity(0.5)
                        )
                    ),
                  ),
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
                    birthdateController.text,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile Updated Successfully!')),
                  );
                },
                child: Text('Save Changes', style: TextStyle(
                  color: Colors.black
                ),),
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
                child: Text('Change Password', style: TextStyle(
                    color: Colors.black
                )),
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
                child: Text('Logout', style: TextStyle(
                    color: Colors.white
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}