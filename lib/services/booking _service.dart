import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';

class BookingService {
  final SupabaseClient supabase;

  BookingService(this.supabase);

  SharedPreferences? sharedPreferences;

  /// Membuat pemesanan baru
  Future<void> createBooking(String facilityId, DateTime bookingDate) async {
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
  }

  Future<List<Map<String, dynamic>>> getUsageReport() async {
    try {
      final response = await supabase.rpc('get_usage_report');
      print('Raw Response: $response'); // Debugging

      if (response is List<dynamic>) {
        final data = response.cast<Map<String, dynamic>>();
        print('Parsed Data: $data'); // Debugging
        return data;
      } else {
        throw Exception('Unexpected response format');
      }
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