import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class BookingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Facility: ${booking['Facilities']['facility_name']}'),
            Text('Date: ${booking['booking_date']}'),
            Text('Status: ${booking['status']}'),
            SizedBox(height: 20),
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey
                )
              ),
              child: Column(
                children: [
                  Text("Tunjukan QR code ke petugas"),
                  const SizedBox(height: 20,),
                  Center(
                    child: BarcodeWidget(
                      barcode: Barcode.qrCode(), // Barcode type and settings
                      data: booking['id'].toString(), // Content
                      width: 200,
                      height: 200,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Kembali ke halaman sebelumnya
              },
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}