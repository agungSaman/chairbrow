import 'package:chairbrow/presentation/auth/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Core/provider/FacilityProvider.dart';
import 'Core/utils/constant.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
      url: AppConstant.EXPO_PUBLIC_SUPABASE_URL,
      anonKey: AppConstant.EXPO_PUBLIC_SUPABASE_ANON_KEY,
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
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FacilityProvider(),
        ),
        // Tambahkan provider lain jika diperlukan
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.white,
            surface: Colors.white
        ),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
