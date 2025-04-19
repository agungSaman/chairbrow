import 'package:chairbrow/services/booking%20_service.dart';
import 'package:chairbrow/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  final BookingService bookingService = BookingService(SupabaseClient(AppConstant.EXPO_PUBLIC_SUPABASE_URL, AppConstant.EXPO_PUBLIC_SUPABASE_ANON_KEY));

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
            // Menampilkan indikator loading saat data sedang diambil
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Menampilkan pesan error jika terjadi kesalahan
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Menampilkan pesan jika tidak ada riwayat pemesanan
            return Center(child: Text('No booking history found.'));
          } else {
            // Menampilkan daftar riwayat pemesanan
            final bookings = snapshot.data!;
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return ListTile(
                  title: Text(booking['facilities']['name']), // Nama fasilitas
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${booking['booking_date']}'), // Tanggal pemesanan
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
                );
              },
            );
          }
        },
      ),
    );
  }
}