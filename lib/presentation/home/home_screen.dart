import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Core/model/ListItem.dart';
import '../../Core/services/booking _service.dart';
import '../../Core/utils/colors.dart';
import '../../dashboard_screen.dart';
import '../bookings/booking_detail_screen.dart';
import '../bookings/booking_screen.dart';

class HomeScreen extends StatefulWidget{
  final BookingService bookingService;
  const HomeScreen({super.key, required this.bookingService});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>{
  late List<ListItem> item;

  @override
  void initState() {
    super.initState();
    item = [];
    _loadItemData();
  }

  Future<void> _loadItemData() async {
    final data = await widget.bookingService.getListItem();
    setState(() {
      final datas = data.map((value) => ListItem.fromJson(value)).toList();
      item = datas.where((element) => element.availability == true).toList();
      log("resultItem ${item[0].image}");
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard"),),
      body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset("assets/icons/ic_logo.png"),

                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Booking Ongoing", style:TextStyle(
                              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold
                          ),),

                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => DashboardScreen(currentPages: 2)),
                                      (root) => false);
                            },
                            child: Text("Lihat Semua", style:TextStyle(
                                color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500
                            ),),
                          )
                        ],
                      ),

                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: widget.bookingService.getBookingHistory(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text('No booking history found.'));
                          } else {
                            final bookings = snapshot.data!.where((booking) => booking['status'] == 'pending').toList();
                            return SizedBox(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: List.generate(bookings.length, (index) {
                                    final booking = bookings[index];
                                    return Container(
                                      margin: EdgeInsets.only(top: 5, bottom: 5),
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
                                  }),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Booking Available", style:TextStyle(
                              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold
                          ),),

                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => DashboardScreen(currentPages: 1)),
                                      (root) => false);
                            },
                            child: Text("Lihat Semua", style:TextStyle(
                                color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500
                            ),),
                          )
                        ],
                      ),

                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
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
                                  width: MediaQuery.of(context).size.width * .70,
                                  margin: EdgeInsets.only(right: 10),
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
                                            height: MediaQuery.of(context).size.height * .15,
                                            width: MediaQuery.of(context).size.width * .3,
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
                                          left: 0,
                                          right: 220,
                                          bottom: 105,
                                          child: CircleAvatar(
                                            backgroundColor: datas.availability == true ? AppColors.secondaryColor : Colors.red,
                                          )
                                      ),

                                      Positioned(
                                          top: 10,
                                          left: 140,
                                          right: 0,
                                          bottom: 90,
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
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}