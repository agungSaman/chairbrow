import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';

import '../model/booking_stats.dart';

class BookingService {
  final SupabaseClient supabase;

  BookingService(this.supabase);

  SharedPreferences? sharedPreferences;

  /// Membuat pemesanan baru
  Future<void> createBooking(String facilityId, String flightNumber, DateTime bookingDate) async {
    // Ambil ID pengguna yang sedang login
    List<Map<String, dynamic>>? custId;
    sharedPreferences = await SharedPreferences.getInstance();
    final userId = sharedPreferences?.getString("user_id");
    if (userId != null) {
      print('Authenticated user UID: $userId');
      custId = await supabase.from('Customers').select('id').eq('user_id', userId);
    } else {
      print('User is not authenticated!');
    }

    // Simpan data pemesanan ke tabel bookings
    await supabase.from('Bookings').insert({
      'user_id': custId?[0]['id'],
      'facility_id': facilityId,
      'booking_date': bookingDate.toIso8601String(),
      'flight_number': flightNumber,
      'status': 'pending',
    });
  }

  /// Mengambil riwayat pemesanan pengguna
  Future<List<Map<String, dynamic>>> getBookingHistory() async {
    // Ambil ID pengguna yang sedang login
    sharedPreferences = await SharedPreferences.getInstance();
    List<Map<String, dynamic>>? custId;
    final userId = sharedPreferences?.getString("user_id");
    if (userId != null) {
      print('Authenticated user UID: $userId');
      custId = await supabase.from('Customers').select('id').eq('user_id', userId);
    } else {
      print('User is not authenticated!');
    }

    // Ambil data pemesanan berdasarkan user_id
    final response = await supabase
        .from('Bookings')
        .select('*, Facilities(id, facility_name)')
        .eq('user_id', custId?[0]['id']??"")
        .order('created_at', ascending: false);

    print("supabaseHistory $response");

    return response;
  }

  Future<List<Map<String, dynamic>>> getAllBookings() async {
    final response = await supabase
        .from('Bookings')
        .select('*, Facilities(id, facility_name)')
        .order('created_at', ascending: false);

    return response;
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    await supabase.from('Bookings').update({
      'status': newStatus,
    }).eq('id', bookingId);

    final response = await supabase
        .from('Bookings')
        .select('*')
        .eq('id', bookingId);

    await supabase.from('Facilities').update({
      'status_usage': 'on-usage',
    }).eq('id', response[0]['facility_id']);
  }

  Future<void> updateBookingSelesai(String bookingId, String newStatus) async {
    final updates = {'status': newStatus};

    if (newStatus == 'done') {
      updates['booking_end_date'] = DateTime.now().toIso8601String();
    }

    await supabase.from('Bookings').update(updates).eq('id', bookingId);

    final response = await supabase
        .from('Bookings')
        .select('facility_id')
        .eq('id', bookingId)
        .single();

    await supabase.from('Facilities').update({
      'status_usage': 'available',
    }).eq('id', response['facility_id']);
  }

  Future<List<BookingStats>> getUsageReport({DateTime? startDate, DateTime? endDate}) async {
    String? startDatePostgresFormat;
    String? endDatePostgresFormat;

    if (startDate != null) {
      startDatePostgresFormat = startDate.toIso8601String().split('.')[0];
    }
    if (endDate != null) {
      endDatePostgresFormat = endDate.toIso8601String().split('.')[0];
    }

    try {
      final response = await supabase.rpc('get_facility_booking_stats', params: {
        'p_start_date': startDatePostgresFormat,
        'p_end_date': endDatePostgresFormat,
      },);

      print('Raw Response: $response'); // Debugging

      if (response is List && response.isNotEmpty) {
        List<BookingStats> bookingReport = response
            .map((item) => BookingStats.fromJson(item as Map<String, dynamic>))
            .toList();

        print('Parsed Report: $bookingReport');
        return bookingReport;
      }
      return [];
    } catch (e) {
      print('Error fetching usage report: ${e.toString()}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getListItem() async {
    final response = await supabase
        .from('Facilities')
        .select();

    print("supabaseItem $response");
    return response;
  }
}