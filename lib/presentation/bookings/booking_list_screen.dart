import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Core/model/ListItem.dart';
import '../../Core/services/booking _service.dart';
import '../../Core/utils/colors.dart';
import '../../Core/utils/constant.dart';
import 'booking_screen.dart';

class BookingListScreen extends StatefulWidget{
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => BookingListScreenState();
}

class BookingListScreenState extends State<BookingListScreen>{
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

  late List<ListItem> item;

  @override
  void initState() {
    super.initState();
    item = [];
    _loadItemData();
  }

  Future<void> _loadItemData() async {
    final data = await bookingService.getListItem();
    setState(() {
      item = data.map((value) => ListItem.fromJson(value)).toList();
      log("resultItem ${item[0].image}");
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking List"),),
      body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(item.length, (index) {
                var datas = item[index];
                return GestureDetector(
                  onTap: () {
                    if (datas.availability == true) {
                      if (datas.statusUsage == "available") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => BookingScreen(item: datas),
                            ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Facility is on-usage')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Facility is not available')),
                      );
                    }
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * .2,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(16)
                    ),
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * .2,
                              width: MediaQuery.of(context).size.width * .4,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                      image:datas.image?.isNotEmpty == true
                                          ? NetworkImage(datas.image??"")
                                          : AssetImage("assets/icons/ic_logo.png"),
                                      fit: BoxFit.fill
                                  )
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.only(left: 5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(datas.facilityName??"", style: TextStyle(
                                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600
                                  ),),
                                  Text(datas.condition??"", style: TextStyle(
                                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500
                                  ),),
                                ],
                              ),
                            )
                          ],
                        ),

                        Positioned(
                            top: 10,
                            left: 10,
                            right: 320,
                            bottom: 132,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: datas.availability == true ? AppColors.secondaryColor : Colors.red,
                                  borderRadius: BorderRadius.circular(24)
                              ),
                            )
                        ),

                        Positioned(
                            top: 10,
                            left: 180,
                            right: 10,
                            bottom: 112,
                            child: Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: datas.statusUsage == "available"
                                        ? Colors.green
                                        : datas.statusUsage == "on-usage"
                                        ? Colors.orange
                                        : Colors.red,
                                  ),
                                  Text(datas.statusUsage??"", style: TextStyle(
                                      color: Colors.black
                                  ))
                                ],
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          )
      ),
    );
  }
}