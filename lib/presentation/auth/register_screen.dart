import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Core/services/auth_service.dart';
import '../../Core/utils/colors.dart';
import '../../Core/utils/constant.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
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

  // Controllers untuk input form
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 120),
                child: Image.asset("assets/icons/ic_logo.png", scale: 3,),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
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

                  birthdateController.text = date.toString();
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
              const SizedBox(height: 16,),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty && nameController.text.isNotEmpty && phoneController.text.isNotEmpty && birthdateController.text.isNotEmpty) {
                    print("register account ${emailController.text} ${passwordController.text}");
                    // Panggil fungsi register dari AuthService
                    await authService.register(
                      emailController.text,
                      passwordController.text,
                      nameController.text,
                      phoneController.text,
                      birthdateController.text,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Registration Successful!')),
                    );
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (root) => false); // Kembali ke halaman sebelumnya
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all fields.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 1,
                  alignment: Alignment.center,
                  child: Text('Register', style: TextStyle(color: AppColors.quaternaryColor),),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (root) => false); // Ke halaman login
                },
                child: Wrap(
                  children: [
                    Text('Sudah punya akun? '),
                    Text('Login here', style: TextStyle(
                      color: AppColors.secondaryColor,
                    ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}