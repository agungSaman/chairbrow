import 'package:chairbrow/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../../Core/provider/FacilityProvider.dart';
import '../../Core/services/booking _service.dart';
import '../../Core/services/facility_service.dart';


class HomeAdmScreen extends StatefulWidget{
  final BookingService bookingService;
  final FacilityService facilityService;
  const HomeAdmScreen({super.key, required this.bookingService, required this.facilityService});

  @override
  State<HomeAdmScreen> createState() => HomeAdmScreenState();
}

class HomeAdmScreenState extends State<HomeAdmScreen> {

  _handleScanResult(BuildContext context, String result) async {
    await widget.bookingService.updateBookingStatus(result, "approved");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated')),
    );
  }

  Future<void> scanQR(BuildContext context) async {
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

    _handleScanResult(context, barcodeScanRes??"");
  }

  @override
  Widget build(BuildContext context) {
    final facilityProvider = Provider.of<FacilityProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Admin'),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset("assets/icons/ic_logo.png"),

                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Booking Ongoing", style:TextStyle(
                              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold
                          ),),

                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => DashboardScreen(currentPages: 1)),
                                      (root) => false);
                            },
                            child: Text("Lihat Semua", style:TextStyle(
                                color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500
                            ),),
                          )
                        ],
                      ),

                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: widget.bookingService.getAllBookings(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text('No bookings found.'));
                          } else {
                            final bookings = snapshot.data!.where((element) => element['status'] == 'pending').toList();
                            return SizedBox(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: List.generate(bookings.length,
                                            (index) {
                                              final booking = bookings[index];
                                              return Container(
                                                margin: EdgeInsets.only(top: 5, bottom: 5),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(16),
                                                    border: Border.all(
                                                        color: Colors.grey
                                                    )
                                                ),
                                                child: ListTile(
                                                  title: Text(booking['Facilities']['facility_name']),
                                                  subtitle: Text('${booking['status']} - ${DateFormat("EE, dd MMMM yyyy, HH:mm").format(DateTime.parse(booking['booking_date'] ))}'),
                                                  trailing: GestureDetector(
                                                    onTap: () {
                                                      // scanQR(context);
                                                    },
                                                    child: Icon(Icons.qr_code_2),
                                                  ),
                                                ),
                                              );
                                            }),
                                  ),
                                )
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Facility Available", style:TextStyle(
                              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold
                          ),),

                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => DashboardScreen(currentPages: 2)),
                                      (root) => false);
                            },
                            child: Text("Lihat Semua", style:TextStyle(
                                color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500
                            ),),
                          )
                        ],
                      ),

                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: widget.facilityService.getAllFacilities(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else {
                            final facilities = snapshot.data!.where((element) => element['availability'] == true).toList();
                            return SizedBox(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(facilities.length,
                                            (index) {
                                          final facility = facilities[index];
                                          return GestureDetector(
                                            onTap: () {
                                              scanQR(context);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              margin: EdgeInsets.only(right: 5, top: 5),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(
                                                      color: Colors.grey
                                                  )
                                              ),
                                              child: Column(
                                                  children: [
                                                    Container(
                                                      height: 100,
                                                      width: 150,
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              image: NetworkImage(facility['image']),
                                                              fit: BoxFit.fill
                                                          )
                                                      ),
                                                    ),
                                                    Text(facility['facility_name']),
                                                    SizedBox(
                                                      height: MediaQuery.of(context).size.height * .05,
                                                      width: MediaQuery.of(context).size.width * .29,
                                                      child: Row(
                                                        children: [
                                                          Switch(
                                                              value: facility['availability'],
                                                              onChanged: (value) async {
                                                                try {
                                                                  await facilityProvider.updateFacility(facility['id'], value, widget.facilityService);
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(content: Text('${facility['facility_name']} updated.')),
                                                                  );
                                                                } catch (e) {
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(content: Text('Error updated facility: ${e.toString()}')),
                                                                  );
                                                                }
                                                              }
                                                          ),
                                                          IconButton(
                                                            icon: Icon(Icons.delete),
                                                            onPressed: () async {
                                                              try {
                                                                await facilityProvider.deleteFacility(facility['id'], widget.facilityService);
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(content: Text('${facility['facility_name']} deleted.')),
                                                                );
                                                              } catch (e) {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(content: Text('Error deleting facility: ${e.toString()}')),
                                                                );
                                                              }
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                )
                            );
                          }
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}