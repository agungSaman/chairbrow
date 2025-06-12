import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../Core/model/booking_stats.dart';
import '../../Core/services/booking _service.dart';


class ReportScreen extends StatelessWidget{
  final BookingService bookingService;
  const ReportScreen({super.key, required this.bookingService});

  Future<void> _downloadExcel(BuildContext context) async {
    try {
      final DateTimeRange? pickedDateRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020, 1, 1),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        currentDate: DateTime.now(),
        helpText: 'Pilih Rentang Tanggal Laporan Excel',
        cancelText: 'Batal',
        confirmText: 'Pilih',
        saveText: 'Download',
      );

      if (pickedDateRange == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pemilihan tanggal untuk Excel dibatalkan.')),
        );
        return;
      }

      final report = await bookingService.getUsageReport(
        startDate: pickedDateRange.start,
        endDate: pickedDateRange.end.add(const Duration(hours: 23, minutes: 59, seconds: 59, microseconds: 999)),
      );


      // Buat file Excel baru
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Header
      sheetObject.appendRow([
        TextCellValue('Tanggal Booking'),
        TextCellValue('Nama'),
        TextCellValue('Umur'),
        TextCellValue('Nomor Penerbangan'),
        TextCellValue('Fasilitas'),
      ]);

      // Isi Data
      for (var entry in report) {
        final bookingDate = entry.bookingDate != null
            ? DateFormat("dd MMM yyyy").format(entry.bookingDate!)
            : "N/A";
        final age = entry.birthDate != null
            ? DateTime.now().year - entry.birthDate!.year
            : "N/A";

        sheetObject.appendRow([
          TextCellValue(bookingDate),
          TextCellValue(entry.name.toString() ?? ''), // Use null-aware operator for safety
          age is int ? IntCellValue(age) : TextCellValue(age.toString()), // Handle age as IntCellValue or TextCellValue
          TextCellValue(entry.flightNumber.toString() ?? ''),
          TextCellValue(entry.facilityName.toString() ?? ''),
        ]);
      }

      // Simpan file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/usage_report.xlsx';

      final file = File(filePath);
      file.writeAsBytesSync(excel.encode()!);

      // Bagikan file
      final result = await SharePlus.instance.share(
        ShareParams(text: 'Laporan Penggunaan Fasilitas', files: [XFile(filePath)]),
      );

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil menyimpan Excel: $filePath')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan Excel: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BookingStats>>(
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
          List<BookingStats> bookings = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('Report'),
            ),
            body: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      border: TableBorder.all(color: Colors.black),
                      columns: const [
                        DataColumn(label: Text('Tanggal Booking')),
                        DataColumn(label: Text('Nama')),
                        DataColumn(label: Text('Umur')),
                        DataColumn(label: Text('Nomor Penerbangan')),
                        DataColumn(label: Text('Fasilitas'))
                      ],
                      rows: List.generate(bookings.length, (index) {
                        final entry = bookings[index];
                        final bookingDate = entry.bookingDate != null ? DateFormat("EE, dd MMMM yyyy").format(entry.bookingDate!) : "N/A";
                        final umur = entry.birthDate?.year != null ? DateTime.now().year - (entry.birthDate?.year??0) : "N/A";
                        return DataRow(
                          cells: [
                            DataCell(Text(bookingDate)),
                            DataCell(Text(entry.name)),
                            DataCell(Text(umur.toString())),
                            DataCell(Text(entry.flightNumber)),
                            DataCell(Text(entry.facilityName)),
                          ],
                        );
                      }),
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: () async {
                    await _downloadExcel(context);
                  },
                  child: Text('Download Excel'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}