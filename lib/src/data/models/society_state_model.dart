class SocietyStateModel {
  final String? societyId;
  final String? apartmentId;
  final String? id;
  final String? block;
  final String? flat;
  final String? society;
  final String? areaId;
  final String? residentType;


  SocietyStateModel({
     this.societyId,
     this.apartmentId,
     this.id,
     this.block,
     this.flat,
     this.society,
     this.areaId,
     this.residentType,
  
  });

  /// Factory constructor to create [SocietyStateModel] from JSON
 factory SocietyStateModel.fromJson(Map<String, dynamic> json) {
  return SocietyStateModel(
    societyId: json['societyId']?.toString(),
    apartmentId: json['apartmentId']?.toString(),
    id: json['id']?.toString(),
    block: json['block'] ?? '',
    flat: json['flat']?.toString(),
    society: json['societyName'] ?? '',
    areaId: json['areaId']?.toString(),
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
