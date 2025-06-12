import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../Core/services/booking _service.dart';
import '../../Core/utils/constant.dart';
import '../bookings/booking_detail_screen.dart';


class HistoryScreen extends StatelessWidget {
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

  HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: bookingService.getBookingHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No booking history found.'));
          } else {
            final bookings = snapshot.data!;
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey
                    ),
                  ),
                  child: ListTile(
                    title: Text(booking['Facilities']['facility_name']), // Nama fasilitas
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${DateFormat('EE, dd MMMM yyyy').format(DateTime.parse(booking['booking_date']))}'), // Tanggal pemesanan
                        Text('Status: ${booking['status']}'), // Status pemesanan
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios), // Ikon panah kanan
                    onTap: () {
                      // Navigasi ke detail pemesanan (opsional)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailScreen(booking: booking),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}