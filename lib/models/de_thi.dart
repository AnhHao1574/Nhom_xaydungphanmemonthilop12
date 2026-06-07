class DeThi {
  final int? id;
  final int monHocId;
  final String maDe;
  final String tenDe;
  final int thoiGian; // Thời gian làm bài (phút)
  final int namThi;
  final int? soThuTu;

  DeThi({
    this.id,
    required this.monHocId,
    required this.maDe,
    required this.tenDe,
    required this.thoiGian,
    required this.namThi,
    this.soThuTu,
  });

  factory DeThi.fromMap(Map<String, dynamic> map) {
    return DeThi(
      id: map['id']?.toInt(),
      monHocId: map['monHocId']?.toInt() ?? 0,
      maDe: map['maDe'] ?? '',
      tenDe: map['tenDe'] ?? '',
      thoiGian: map['thoiGian']?.toInt() ?? 50, // Mặc định 50 phút
      namThi: map['namThi']?.toInt() ?? DateTime.now().year,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monHocId': monHocId,
      'maDe': maDe,
      'tenDe': tenDe,
      'thoiGian': thoiGian,
      'namThi': namThi,
    };
  }
}