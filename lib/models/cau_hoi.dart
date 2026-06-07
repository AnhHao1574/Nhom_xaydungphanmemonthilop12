class CauHoi {
  final int? id;
  final int deThiId;
  final String noiDung;
  final String dapAnA;
  final String dapAnB;
  final String dapAnC;
  final String dapAnD;
  final String dapAnDung; // 'A', 'B', 'C', 'D'
  final String? giaiThich;

  CauHoi({
    this.id,
    required this.deThiId,
    required this.noiDung,
    required this.dapAnA,
    required this.dapAnB,
    required this.dapAnC,
    required this.dapAnD,
    required this.dapAnDung,
    this.giaiThich,
  });

  factory CauHoi.fromMap(Map<String, dynamic> map) {
    return CauHoi(
      id: map['id']?.toInt(),
      deThiId: map['deThiId']?.toInt() ?? 0,
      noiDung: map['noiDung'] ?? '',
      dapAnA: map['dapAnA'] ?? '',
      dapAnB: map['dapAnB'] ?? '',
      dapAnC: map['dapAnC'] ?? '',
      dapAnD: map['dapAnD'] ?? '',
      dapAnDung: map['dapAnDung'] ?? '',
      giaiThich: map['giaiThich'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deThiId': deThiId,
      'noiDung': noiDung,
      'dapAnA': dapAnA,
      'dapAnB': dapAnB,
      'dapAnC': dapAnC,
      'dapAnD': dapAnD,
      'dapAnDung': dapAnDung,
      'giaiThich': giaiThich,
    };
  }
}