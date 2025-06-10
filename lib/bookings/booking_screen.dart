import 'package:chairbrow/services/booking%20_service.dart';
import 'package:chairbrow/utils/colors.dart';
import 'package:chairbrow/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/ListItem.dart';

class BookingScreen extends StatelessWidget {
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

  final TextEditingController facilityController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  final ListItem item;

  BookingScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    facilityController.text = item.facilityName??"";
    return Scaffold(
      appBar: AppBar(title: Text('Booking Facility')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: facilityController,
              decoration: InputDecoration(
                labelText: 'Facility',
                hintText:  item.facilityName == "" ? null : item.facilityName,
                enabled: false,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10,),
            GestureDetector(
              onTap: () {
                var date = showDatePicker(
                    context: context,
                    firstDate: DateTime(1900, 1, 1),
                    lastDate: DateTime(2125, 1, 1));

                date.then((value) {
                  dateController.text = value.toString();
                });
              },
              child: TextField(
                controller: dateController,
                enabled: false,
                decoration: InputDecoration(
                    label: Text('Date & Time'),
                    labelStyle: TextStyle(color: Colors.black),
                    disabledBorder: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () async {
                await bookingService.createBooking(
                  item.id??"",
                  DateTime.parse(dateController.text),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Booking Successful!')),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 1,
                alignment: Alignment.center,
                child: Text('Submit Booking', style: TextStyle(color: AppColors.quaternaryColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}