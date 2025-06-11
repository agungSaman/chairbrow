import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/booking _service.dart';

class ReportScreen extends StatelessWidget{
  final BookingService bookingService;
  const ReportScreen({super.key, required this.bookingService});

  Future<void> _downloadCSV(BuildContext context) async {
    try {
      // Ambil data laporan
      final report = await bookingService.getUsageReport();

      // Konversi data ke format CSV
      List<List<dynamic>> rows = [];
      rows.add(['Facility Name', 'Total Bookings', 'Approved', 'Pending']); // Header
      for (var entry in report) {
        rows.add([
          entry['facility_name'],
          entry['total_bookings'],
          entry['approved_count'],
          entry['pending_count'],
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);

      // Simpan file CSV ke direktori lokal
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/usage_report.csv';
      final file = File(filePath);
      await file.writeAsString(csvData);

      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV file downloaded: $filePath')),
      );

      final params = ShareParams(
        text: 'Usage Report',
        files: [XFile(filePath)],
        downloadFallbackEnabled: false,
      );

      final result = await SharePlus.instance.share(params);

      if (result.status == ShareResultStatus.success) {
        print('Thank you for sharing the picture!');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading CSV: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: bookingService.getUsageReport(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print("snapshoterror ${snapshot.error}");
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No usage report available.'));
        } else {
          final report = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('Usage Report'),
            ),
            body: Column(
              children: [
                Expanded(
                    child: ListView.builder(
                      itemCount: report.length,
                      itemBuilder: (context, index) {
                        final entry = report[index];
                        return ListTile(
                          title: Text(entry['facility_name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Bookings: ${entry['total_bookings']}'),
                              Text('Approved: ${entry['approved_count']}'),
                              Text('Pending: ${entry['pending_count']}'),
                            ],
                          ),
                        );
                      },
                    )
                ),

                ElevatedButton(
                  onPressed: () async {
                    await _downloadCSV(context);
                  },
                  child: Text('Download CSV'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}