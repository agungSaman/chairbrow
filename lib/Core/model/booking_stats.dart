class BookingStats {
  final String facilityName;
  final DateTime? bookingDate;
  final String name;
  final DateTime? birthDate;
  final String flightNumber;

  BookingStats({
    required this.facilityName,
    this.bookingDate,
    required this.name,
    this.birthDate,
    required this.flightNumber,
  });

  // Fungsi untuk parsing JSON ke model
  factory BookingStats.fromJson(Map<String, dynamic> json) {
    return BookingStats(
      facilityName: json['facility_name'] ?? 'N/A',
      bookingDate: json['booking_date'] != null ? DateTime.parse(json['booking_date']) : null,
      name: json['name'] ?? 'N/A',
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
      flightNumber: json['flight_number'] ?? 'N/A',
    );
  }
}