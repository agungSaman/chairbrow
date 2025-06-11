import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../services/booking _service.dart';

class BookingAdmScreen extends StatelessWidget{
  final BookingService bookingService;
  const BookingAdmScreen({super.key, required this.bookingService});

  _handleScanResult(BuildContext context, String result) async {
    await bookingService.updateBookingStatus(result, "approved");
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
    return FutureBuilder<List<Map<String, dynamic>>>(
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
          return Scaffold(
            appBar: AppBar(
              title: Text('Bookings'),
            ),
            body: ListView.builder(
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
                    subtitle: Text('${booking['status']} - ${DateFormat("EE, dd MMMM yyyy, HH:mm").format(DateTime.parse(booking['booking_date'] ))}'),
                    trailing: GestureDetector(
                      onTap: () {
                        scanQR(context);
                      },
                      child: Icon(Icons.qr_code_2),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}