import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Core/services/booking _service.dart';
import '../../Core/utils/constant.dart';

class BookingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> booking;
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


  BookingDetailScreen({super.key, required this.booking});

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
            Visibility(
              visible: booking['status'] == "pending" || booking['status'] == "approved",
              child: ElevatedButton(
                onPressed: () async {
                  bool confirm = await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Batalkan Booking'),
                      content: Text('Apakah kamu yakin ingin membatalkan booking ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Tidak'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Ya'),
                        ),
                      ],
                    ),
                  );

                  if (confirm) {
                    await bookingService.updateBookingSelesai(
                      booking['id'].toString(),
                      "cancelled",
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booking dibatalkan')),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Text(
                    'Batalkan Booking',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Visibility(
                visible: booking['status'] == "done" || booking['status'] == "pending" ? false : true,
                child: ElevatedButton(
                  onPressed: () {
                    bookingService.updateBookingSelesai(booking['id'].toString(), "done");
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Text('Selesai', style: TextStyle(
                        color: Colors.white
                    ),),
                  ),
                )
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Kembali ke halaman sebelumnya
              },
              child: Text('Kembali', style: TextStyle(
                  color: Colors.black
              )),
            ),
          ],
        ),
      ),
    );
  }
}