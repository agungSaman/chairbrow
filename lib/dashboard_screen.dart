import 'dart:io';

import 'package:chairbrow/services/booking%20_service.dart';
import 'package:chairbrow/services/facility_service.dart';
import 'package:chairbrow/services/user_service.dart';
import 'package:chairbrow/settings_screen.dart';
import 'package:chairbrow/utils/colors.dart';
import 'package:chairbrow/utils/constant.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'add_facility_screen.dart';
import 'booking_list_screen.dart';
import 'history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    userRoles = "";
    tabController = TabController(length: 4, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await userService.getUserProfile();
    setState(() {
      userRoles = userData['user_role'];
    });
  }

  Future<void> _downloadCSV(BuildContext context) async {
    try {
      // Ambil data laporan
      final report = await bookingService.getUsageReport();

      // Konversi data ke format CSV
      List<List<dynamic>> rows = [];
      rows.add(['Facility Name', 'Total Bookings', 'Approved', 'Pending']); // Header
      for (var entry in report) {
        rows.add([
          entry['facility_name'],
          entry['total_bookings'],
          entry['approved_count'],
          entry['pending_count'],
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);

      // Simpan file CSV ke direktori lokal
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/usage_report.csv';
      final file = File(filePath);
      await file.writeAsString(csvData);

      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV file downloaded: $filePath')),
      );

      final params = ShareParams(
        text: 'Usage Report',
        files: [XFile(filePath)],
        downloadFallbackEnabled: false,
      );

      final result = await SharePlus.instance.share(params);

      if (result.status == ShareResultStatus.success) {
        print('Thank you for sharing the picture!');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading CSV: ${e.toString()}')),
      );
    }
  }

  _handleScanResult(String result) async {
    await bookingService.updateBookingStatus(result, "approved");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated')),
    );
  }

  Future<void> scanQR() async {
    String? barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await SimpleBarcodeScanner.scanBarcode(
        context,
        barcodeAppBar: const BarcodeAppBar(
          appBarTitle: 'Scan Kode Booking',
          centerTitle: false,
          enableBackButton: true,
          backButtonIcon: Icon(Icons.arrow_back_ios),
        ),
        isShowFlashIcon: true,
        delayMillis: 2000,
        cameraFace: CameraFace.front,
      );
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _handleScanResult(barcodeScanRes??"");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userRoles == "users") {
      return Scaffold(
        appBar: AppBar(title: Text('Dashboard')),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookingListScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 1,
                  alignment: Alignment.center,
                  child: Text('Booking Facility', style: TextStyle(color: AppColors.quaternaryColor)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 1,
                  alignment: Alignment.center,
                  child: Text('View History', style: TextStyle(color: AppColors.quaternaryColor)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 1,
                  alignment: Alignment.center,
                  child: Text('Account Settings', style: TextStyle(color: AppColors.quaternaryColor)),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Admin Dashboard'),
          bottom: TabBar(
            controller: tabController,
            tabs: [
              Tab(text: 'Bookings'),
              Tab(text: 'Facilities'),
              Tab(text: 'Usage Report'),
              Tab(text: "Settings",)
            ],
          ),
        ),
        body: TabBarView(
            controller: tabController,
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: bookingService.getAllBookings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No bookings found.'));
                  } else {
                    final bookings = snapshot.data!;
                    return ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey
                            )
                          ),
                          child: ListTile(
                            title: Text(booking['Facilities']['facility_name']),
                            subtitle: Text('${booking['status']} - ${DateFormat("EE, dd MMMM yyyy").format(DateTime.parse(booking['booking_date'] ))}'),
                            trailing: GestureDetector(
                              onTap: () {
                                scanQR();
                              },
                              child: Icon(Icons.qr_code_2),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),

              FutureBuilder<List<Map<String, dynamic>>>(
                future: facilityService.getAllFacilities(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final facilities = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: facilities.length,
                      itemBuilder: (context, index) {
                        final facility = facilities[index];
                        return ListTile(
                          title: Text(facility['facility_name']),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              await facilityService.deleteFacility(facility['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${facility['name']} deleted.')),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),

              FutureBuilder<List<Map<String, dynamic>>>(
                future: bookingService.getUsageReport(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print("snapshoterror ${snapshot.error}");
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No usage report available.'));
                  } else {
                    final report = snapshot.data!;
                    return Column(
                      children: [
                        Expanded(
                            child: ListView.builder(
                              itemCount: report.length,
                              itemBuilder: (context, index) {
                                final entry = report[index];
                                return ListTile(
                                  title: Text(entry['facility_name']),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Total Bookings: ${entry['total_bookings']}'),
                                      Text('Approved: ${entry['approved_count']}'),
                                      Text('Pending: ${entry['pending_count']}'),
                                    ],
                                  ),
                                );
                              },
                            )
                        ),

                        ElevatedButton(
                          onPressed: () async {
                            await _downloadCSV(context);
                          },
                          child: Text('Download CSV'),
                        ),
                      ],
                    );
                  }
                },
              ),

              SettingsScreen(),
            ]
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddFacilityDialog(facilityService: facilityService),
            );
          },
          child: Icon(Icons.add),
        ),
      );
    }
  }
}