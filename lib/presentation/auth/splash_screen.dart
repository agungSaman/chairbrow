import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Core/services/auth_service.dart';
import '../../Core/utils/colors.dart';
import '../../Core/utils/constant.dart';
import '../../dashboard_screen.dart';
import 'LoginRegisterScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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

  @override
  void initState() {
    super.initState();

    checkUserLogin();
  }

  checkUserLogin() async {
    final result = await authService.checkUserLogin();
    if (result == true) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => DashboardScreen(currentPages: 0,)), (root) => false);
    } else {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginRegisterScreen()), (root) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bandara APT Pranoto',
              style: TextStyle(fontSize: 24, color: AppColors.quaternaryColor, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}