import 'package:chairbrow/dashboard_screen.dart';
import 'package:chairbrow/presentation/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Core/services/auth_service.dart';
import '../../Core/utils/colors.dart';
import '../../Core/utils/constant.dart';

class LoginScreen extends StatelessWidget {
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
      )
  );

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
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
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),

              ),
              const SizedBox(height: 10,),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15,),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                            builder: (c, setStates) {
                              return Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16)
                                  )
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20,),
                                    Text("Masukan Password baru Anda", style: TextStyle(
                                      color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500
                                    ),),
                                    const SizedBox(height: 10,),
                                    TextField(
                                      controller: passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Password Baru',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await authService.changePassword(passwordController.text);
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.secondaryColor,
                                      ),
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 1,
                                        alignment: Alignment.center,
                                        child: Text('Simpan', style: TextStyle(color: AppColors.quaternaryColor),),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }
                        );
                      }
                  );
                },
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text('Lupa Password?', textAlign: TextAlign.right, style: TextStyle(
                      color: Colors.blue
                  ),),
                )
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () async {
                  final result = await authService.login(emailController.text, passwordController.text);
                  if (result == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Login Successful!')),
                    );
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => DashboardScreen(currentPages: 0,)), (root) => false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Login Failed!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 1,
                  alignment: Alignment.center,
                  child: Text('Login', style: TextStyle(color: AppColors.quaternaryColor),),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => RegisterScreen()), (root) => false);
                },
                child: Wrap(
                  children: [
                    Text('Belum punya akun? '),
                    Text('Register', style: TextStyle(
                      color: AppColors.secondaryColor,
                    ),)
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