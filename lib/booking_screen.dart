import 'package:chairbrow/services/booking%20_service.dart';
import 'package:chairbrow/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingScreen extends StatelessWidget {
  final BookingService bookingService = BookingService(SupabaseClient(AppConstant.EXPO_PUBLIC_SUPABASE_URL, AppConstant.EXPO_PUBLIC_SUPABASE_ANON_KEY));

  final TextEditingController facilityController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking Facility')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: facilityController,
              decoration: InputDecoration(labelText: 'Facility'),
            ),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Date & Time'),
            ),
            ElevatedButton(
              onPressed: () async {
                await bookingService.createBooking(
                  facilityController.text,
                  DateTime.parse(dateController.text),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Booking Successful!')),
                );
              },
              child: Text('Submit Booking'),
            ),
          ],
        ),
      ),
    );
  }
}