import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Core/model/ListItem.dart';
import '../../Core/services/booking _service.dart';
import '../../Core/services/user_service.dart';
import '../../Core/utils/colors.dart';
import '../../Core/utils/constant.dart';

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

  final UserService userService = UserService(
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController flightnumberController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  final ListItem item;
  late bool isSelected = false;
  late String dateBooking = "";
  late String birthDate = "";

  BookingScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    facilityController.text = item.facilityName??"";
    return Scaffold(
      appBar: AppBar(title: Text('Booking Facility')),
      body: StatefulBuilder(
          builder: (c, setStates) {
            return Padding(
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
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      labelStyle: TextStyle(color: Colors.black),
                      hintText:  '',
                      hintStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                          )
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                          )
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.black),
                      hintText:  '',
                      hintStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                          )
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                          )
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  GestureDetector(
                    onTap: () async {
                      var date = await showDatePicker(
                          context: context,
                          currentDate: DateTime.now(),
                          initialEntryMode: DatePickerEntryMode.calendar,
                          firstDate: DateTime(1900, 1, 1),
                          lastDate: DateTime(2125, 1, 1));

                      birthdateController.text = (DateTime.now().year - (date?.year??0)).toString();
                      birthDate = date?.toIso8601String()??"";
                      print("Umur ${birthdateController.text}");
                    },
                    child: TextField(
                      controller: birthdateController,
                      enabled: false,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        label: Text('Umur'),
                        labelStyle: TextStyle(color: Colors.black),
                        disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.3)
                            )
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  TextField(
                    controller: flightnumberController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Flight Number',
                      labelStyle: TextStyle(color: Colors.black),
                      hintText:  '',
                      hintStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                          )
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                          )
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  TextField(
                    controller: descController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Keterangan',
                      labelStyle: TextStyle(color: Colors.black),
                      hintText:  '',
                      hintStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                          )
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
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

                        final dateNow = DateTime(value?.year??0, value?.month??0, value?.day??0, time?.hour??0, time?.minute??0);

                        dateController.text = DateFormat('EE, dd MMMM yyyy HH:mm WIB').format(dateNow);
                        dateBooking = dateNow.toIso8601String();
                        print("tanggal booking $dateBooking");
                      });
                    },
                    child: TextField(
                      controller: dateController,
                      enabled: false,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        label: Text('Tanggal dan Waktu Pemesanan'),
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
                  Row(
                    children: [
                      Checkbox(
                          value: isSelected,
                          onChanged: (val) async {
                            if (isSelected == false) {
                              final data = await userService.getUserProfile();
                              if (data['birth_date'].toString().isNotEmpty) {
                                setStates(() {
                                  isSelected = true;
                                  nameController.text = data['name'];
                                  emailController.text = data['email'];
                                  birthdateController.text = (DateTime.now().year - (DateTime.parse(data['birth_date'] ?? '').year)).toString();
                                  birthDate = data['birth_date'];
                                });
                              } else {
                                setStates(() {
                                  isSelected = false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Silakan isi tanggal lahir anda di pengaturan profile')),
                                  );
                                });
                              }
                            } else {
                              setStates(() {
                                isSelected = false;
                                nameController.text = "";
                                emailController.text = "";
                                birthdateController.text = "";
                                birthDate = "";
                              });
                            }
                          }
                      ),

                      Text("Gunakan data akun sebagai pemesan")
                    ],
                  ),
                  const SizedBox(height: 20,),
                  ElevatedButton(
                    onPressed: () async {
                      if (isSelected == true) {
                        await bookingService.createBooking(
                          item.id??"",
                          flightnumberController.text,
                          DateTime.parse(dateBooking),
                        );
                      } else {
                        await userService.addNewCustomers(
                          emailController.text,
                          "AAaa@1234",
                          nameController.text,
                          "08123456789",
                          birthDate,
                        );

                        await bookingService.createBooking(
                          item.id??"",
                          flightnumberController.text,
                          DateTime.parse(dateBooking),
                        );
                      }

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
            );
          }
      ),
    );
  }
}