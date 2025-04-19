import 'dart:developer';

import 'package:chairbrow/model/ListItem.dart';
import 'package:chairbrow/services/booking%20_service.dart';
import 'package:chairbrow/utils/colors.dart';
import 'package:chairbrow/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final data = await bookingService.getListItem();;
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookingScreen(item: datas),
                    ));
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * .2,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(16)
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * .2,
                          width: MediaQuery.of(context).size.width * .4,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                  image: NetworkImage(datas.image??""),
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
                  ),
                );
              }),
            ),
          )
      ),
    );
  }
}