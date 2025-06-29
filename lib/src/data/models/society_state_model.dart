class SocietyStateModel {
  final String societyId;
  final String apartmentId;
  final String id;
  final String block;
  final String flat;
  final String society;
  final String areaId;
  final String residentType;

  SocietyStateModel({
    required this.societyId,
    required this.apartmentId,
    required this.id,
    required this.block,
    required this.flat,
    required this.society,
    required this.areaId,
    required this.residentType,
  });

  /// Factory constructor to create [SocietyStateModel] from JSON
  factory SocietyStateModel.fromJson(Map<String, dynamic> json) {
    return SocietyStateModel(
      societyId: json['societyId'] ?? '',
      apartmentId: json['apartmentId'] ?? '',
      id: json['id'] ?? '',
      block: json['block'] ?? '',
      flat: json['flat'] ?? '',
      society: json['society'] ?? '',
      areaId: json['areaId'] ?? '',
      residentType: json['residentType'] ?? '',
    );
  }

  /// Convert [SocietyStateModel] to JSON
  Map<String, dynamic> toJson() {
    return {
      'societyId': societyId,
      'apartmentId': apartmentId,
      'id': id,
      'block': block,
      'flat': flat,
      'society': society,
      'areaId': areaId,
      'residentType': residentType,
    };
  }

  SocietyStateModel copyWith({
    String? societyId,
    String? apartmentId,
    String? id,
    String? block,
    String? flat,
    String? society,
    String? areaId,
    String? residentType,
  }) {
    return SocietyStateModel(
      societyId: societyId ?? this.societyId,
      apartmentId: apartmentId ?? this.apartmentId,
      id: id ?? this.id,
      block: block ?? this.block,
      flat: flat ?? this.flat,
      society: society ?? this.society,
      areaId: areaId ?? this.areaId,
      residentType: residentType ?? this.residentType,
    );
  }

  @override
  String toString() {
    return 'SocietyStateModel(societyId: $societyId, apartmentId: $apartmentId, id: $id, block: $block, flat: $flat, society: $society, areaId: $areaId, residentType: $residentType)';
  }
}
