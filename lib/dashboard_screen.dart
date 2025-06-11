import 'package:chairbrow/report/report_screen.dart';
import 'package:chairbrow/services/booking%20_service.dart';
import 'package:chairbrow/services/facility_service.dart';
import 'package:chairbrow/services/user_service.dart';
import 'package:chairbrow/settings_screen.dart';
import 'package:chairbrow/utils/colors.dart';
import 'package:chairbrow/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bookings/booking_adm_screen.dart';
import 'facilities/add_facility_screen.dart';
import 'bookings/booking_list_screen.dart';
import 'facilities/facilities_screen.dart';
import 'history_screen.dart';
import 'home/home_adm_screen.dart';
import 'home/home_screen.dart';

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
            currentIndex: currentPage,
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
                  label: "Setting"
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
                  label: "Usage Report"
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_box, color: Colors.grey,),
                  activeIcon: Icon(Icons.account_box, color: AppColors.primaryColor,),
                  label: "Setting"
              ),
            ]
        ),
      );
    }
  }
}