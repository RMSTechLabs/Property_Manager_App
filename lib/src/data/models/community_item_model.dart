// Data models
class CommunityItem {
  final String id;
  final String name;
  final String residentType;
  final String ownerOrTenantName;
  final String societyId;
  final String apartmentId;
  final String areaId;

  CommunityItem({
    required this.id,
    required this.name,
    required this.residentType,
    required this.ownerOrTenantName,
    required this.societyId,
    required this.apartmentId,
    required this.areaId,
  });
}
