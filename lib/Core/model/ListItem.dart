class ListItem {
  ListItem({
    this.id,
    this.facilityName,
    this.availability,
    this.condition,
    this.image,
    this.statusUsage,
  });

  final String? id;
  final String? facilityName;
  final bool? availability;
  final String? condition;
  final String? image;
  final String? statusUsage;

  factory ListItem.fromJson(Map<String, dynamic> json){
    return ListItem(
      id: json["id"] ?? "",
      facilityName: json["facility_name"] ?? "",
      availability: json["availability"] ?? false,
      condition: json["condition"] ?? "",
      image: json["image"] ?? "",
      statusUsage: json["status_usage"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "facility_name": facilityName,
    "availability": availability,
    "condition": condition,
    "image": image,
    "status_usage": statusUsage,
  };
}