import 'package:supabase/supabase.dart';

class BookingService {
  final SupabaseClient supabase;

  BookingService(this.supabase);

  /// Membuat pemesanan baru
  Future<void> createBooking(String facilityName, DateTime bookingDate) async {
    // Ambil ID pengguna yang sedang login
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    // Cari ID fasilitas berdasarkan nama fasilitas
    final facilityResponse = await supabase
        .from('facilities')
        .select('id')
        .eq('name', facilityName)
        .single();

    final facilityId = facilityResponse['id'];

    // Simpan data pemesanan ke tabel bookings
    await supabase.from('bookings').insert({
      'user_id': userId,
      'facility_id': facilityId,
      'booking_date': bookingDate.toIso8601String(),
      'status': 'pending',
    });
  }

  /// Mengambil riwayat pemesanan pengguna
  Future<List<Map<String, dynamic>>> getBookingHistory() async {
    // Ambil ID pengguna yang sedang login
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    // Ambil data pemesanan berdasarkan user_id
    final response = await supabase
        .from('bookings')
        .select('*, facilities(name)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response;
  }
}