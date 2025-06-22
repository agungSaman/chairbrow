import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../../Core/services/booking _service.dart';

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

  String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return "$hours jam $minutes menit";
  }

  Widget buildBookingList(List<Map<String, dynamic>> bookings, BuildContext context) {
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final startTime = DateTime.parse(booking['booking_date']);
        final endTime = DateTime.tryParse(booking['booking_end_date'] ?? '') ?? DateTime.now();
        final duration = endTime.difference(startTime);

        return Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey)),
          child: ListTile(
            title: Text(booking['Facilities']['facility_name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${booking['status']} - ${DateFormat("EE, dd MMMM yyyy, HH:mm").format(startTime)}'),
                if (booking['status'] == "done")
                  Text('Lama Peminjaman : ${formatDuration(duration)}')
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (booking['status'] == "approved")
                  GestureDetector(
                    onTap: () {
                      bookingService.updateBookingSelesai(
                          booking['id'].toString(), "done");
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.orange)),
                      child: Icon(Icons.done_all, color: Colors.orange),
                    ),
                  ),
                if (booking['status'] == "pending")
                  GestureDetector(
                    onTap: () => scanQR(context),
                    child: Icon(Icons.qr_code_2),
                  ),
                if (booking['status'] == "done")
                  Icon(Icons.done_outline_sharp, color: Colors.green),
                if (booking['status'] == "cancelled")
                  Text('Dibatalkan oleh pengguna', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: bookingService.getAllBookings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(title: Text('Bookings')),
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(title: Text('Bookings')),
                body: Center(child: Text('Error: ${snapshot.error}')),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: Text('Bookings')),
                body: Center(child: Text('No bookings found.')),
              );
            } else {
              final bookings = snapshot.data!;
              final pendingBookings =
              bookings.where((b) => b['status'] == 'pending').toList();
              final approvedBookings =
              bookings.where((b) => b['status'] == 'approved').toList();
              final doneBookings = bookings
                  .where((b) => b['status'] == 'done' || b['status'] == 'cancelled')
                  .toList();
              return Scaffold(
                appBar: AppBar(
                  title: Text('Bookings'),
                  bottom: TabBar(
                    tabs: [
                      Tab(text: 'In Comming'),
                      Tab(text: 'On Progress'),
                      Tab(text: 'Done'),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    buildBookingList(pendingBookings, context),
                    buildBookingList(approvedBookings, context),
                    buildBookingList(doneBookings, context),
                  ],
                ),
              );
            }
          },
        )
    );
  }
}