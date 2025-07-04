// Location Model
class LocationModel {
  final String id;
  final String locationName;
  final String? apartmentId;
  final String? areaId;
  final String? societyId;

  LocationModel({required this.id, required this.locationName, this.apartmentId, this.areaId, this.societyId});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'].toString(),
      locationName: json['locationName'] ?? json['name'] ?? '',
      apartmentId: json['apartmentId']?.toString(),
      areaId: json['areaId']?.toString(),
      societyId: json['societyId']?.toString(),
    );
  }
}