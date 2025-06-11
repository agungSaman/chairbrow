import 'package:chairbrow/services/booking%20_service.dart';
import 'package:chairbrow/utils/colors.dart';
import 'package:chairbrow/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Facility',
                labelStyle: TextStyle(color: Colors.black),
                hintText:  item.facilityName == "" ? null : item.facilityName,
                hintStyle: TextStyle(color: Colors.black),
                enabled: false,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black
                  )
                ),
              ),
            ),
            const SizedBox(height: 10,),
            GestureDetector(
              onTap: () {
                var date = showDatePicker(
                    context: context,
                    currentDate: DateTime.now(),
                    initialEntryMode: DatePickerEntryMode.calendar,
                    firstDate: DateTime(1900, 1, 1),
                    lastDate: DateTime(2125, 1, 1));

                date.then((value) async {
                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: value?.hour??0,
                          minute: value?.minute??0)
                  );

                  dateController.text = "${DateFormat('yyyy-MM-dd').format(value??DateTime.now())} ${time?.hour}:${time?.minute}:00";
                });
              },
              child: TextField(
                controller: dateController,
                enabled: false,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    label: Text('Date & Time'),
                    labelStyle: TextStyle(color: Colors.black),
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3)
                        )
                    ),
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