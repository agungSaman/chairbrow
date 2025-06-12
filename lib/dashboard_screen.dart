import 'package:chairbrow/presentation/bookings/booking_adm_screen.dart';
import 'package:chairbrow/presentation/bookings/booking_list_screen.dart';
import 'package:chairbrow/presentation/facilities/add_facility_screen.dart';
import 'package:chairbrow/presentation/facilities/facilities_screen.dart';
import 'package:chairbrow/presentation/history/history_screen.dart';
import 'package:chairbrow/presentation/home/home_adm_screen.dart';
import 'package:chairbrow/presentation/home/home_screen.dart';
import 'package:chairbrow/presentation/profile/settings_screen.dart';
import 'package:chairbrow/presentation/report/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Core/services/booking _service.dart';
import 'Core/services/facility_service.dart';
import 'Core/services/user_service.dart';
import 'Core/utils/colors.dart';
import 'Core/utils/constant.dart';

class DashboardScreen extends StatefulWidget {
  final int currentPages;
  const DashboardScreen({super.key, required this.currentPages});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
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

  final BookingService bookingService = BookingService(
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

  final FacilityService facilityService = FacilityService(
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

  late TabController tabController;
  late String userRoles;
  late List<Map<String, dynamic>> facilities;
  late List<Widget> pages;
  late List<Widget> pages1;
  late int currentPage;

  @override
  void initState() {
    super.initState();
    userRoles = "";
    currentPage = widget.currentPages;
    facilities = [];
    tabController = TabController(length: 4, vsync: this);

    pages = [
      HomeScreen(bookingService: bookingService,),
      BookingListScreen(),
      HistoryScreen(),
      SettingsScreen(),
    ];

    pages1 = [
      HomeAdmScreen(bookingService: bookingService, facilityService: facilityService,),
      BookingAdmScreen(bookingService: bookingService),
      FacilitiesTab(facilityService: facilityService),
      ReportScreen(bookingService: bookingService),
      SettingsScreen(),
    ];

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await userService.getUserProfile();
    setState(() {
      userRoles = userData['user_role'];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userRoles == "users") {
      return Scaffold(
        body: Container(
          padding: EdgeInsets.all(10),
          child: pages[currentPage],
        ),
        bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: Colors.grey.withOpacity(0.5),
            currentIndex: currentPage,
            showUnselectedLabels: true,
            onTap: (val) {
              setState(() {
                currentPage = val;
              });
            },
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home, color: Colors.grey,),
                  activeIcon: Icon(Icons.home, color: AppColors.primaryColor,),
                  label: "Home"
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.accessible_outlined, color: Colors.grey,),
                  activeIcon: Icon(Icons.accessible_outlined, color: AppColors.primaryColor,),
                  label: "Booking"
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history, color: Colors.grey,),
                  activeIcon: Icon(Icons.history, color: AppColors.primaryColor,),
                  label: "History"
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_box, color: Colors.grey,),
                  activeIcon: Icon(Icons.account_box, color: AppColors.primaryColor,),
                  label: "Profile"
              ),
            ]
        ),
      );
    } else {
      return Scaffold(
        body: Container(
          padding: EdgeInsets.all(10),
          child: pages1[currentPage],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => AddFacilityDialog(facilityService: facilityService),
            );
          },
          child: Icon(Icons.add),
        ),
        bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: AppColors.primaryColor,
            currentIndex: currentPage,
            unselectedItemColor: Colors.grey.withOpacity(0.5),
            showUnselectedLabels: true,
            onTap: (val) {
              setState(() {
                currentPage = val;
              });
            },
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home, color: Colors.grey,),
                  activeIcon: Icon(Icons.home, color: AppColors.primaryColor,),
                  label: "Home"
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined, color: Colors.grey,),
                  activeIcon: Icon(Icons.receipt_long_outlined, color: AppColors.primaryColor,),
                  label: "Bookings"
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.accessible_sharp, color: Colors.grey,),
                  activeIcon: Icon(Icons.accessible_sharp, color: AppColors.primaryColor,),
                  label: "Facilities"
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.report_gmailerrorred, color: Colors.grey,),
                  activeIcon: Icon(Icons.report_gmailerrorred, color: AppColors.primaryColor,),
                  label: "Report"
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_box, color: Colors.grey,),
                  activeIcon: Icon(Icons.account_box, color: AppColors.primaryColor,),
                  label: "Profile"
              ),
            ]
        ),
      );
    }
  }
}