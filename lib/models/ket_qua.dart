import 'dart:convert';

class KetQua {
  final int? id;
  final int? maNguoiDung;
  final int deThiId;
  final String? tenDeThi;
  final double diem;
  final int soCauDung;
  final int soCauSai;
  final int thoiGianLam;
  final DateTime ngayThi;
  final String? danhSachDapAnChon;

  KetQua({
    this.id,
    this.maNguoiDung,
    required this.deThiId,
    this.tenDeThi,
    required this.diem,
    required this.soCauDung,
    required this.soCauSai,
    required this.thoiGianLam,
    required this.ngayThi,
    this.danhSachDapAnChon,
  });

  Map<int, String> get dapAnDaChon {
    if (danhSachDapAnChon == null || danhSachDapAnChon!.isEmpty) {
      return {};
    }
    try {
      final decoded = jsonDecode(danhSachDapAnChon!) as Map<String, dynamic>;
      final raw = decoded['dapAn'] ?? decoded;
      if (raw is Map<String, dynamic>) {
        return raw.map((k, v) => MapEntry(int.parse(k), v as String));
      }
    } catch (_) {}
    return {};
  }

  int get thoiGianLamTuJson {
    if (danhSachDapAnChon == null || danhSachDapAnChon!.isEmpty) {
      return thoiGianLam;
    }
    try {
      final decoded = jsonDecode(danhSachDapAnChon!) as Map<String, dynamic>;
      return decoded['thoiGianLam'] as int? ?? thoiGianLam;
    } catch (_) {
      return thoiGianLam;
    }
  }

  factory KetQua.fromMap(Map<String, dynamic> map) {
    return KetQua(
      id: map['id'] ?? map['MaLichSu'],
      maNguoiDung: map['maNguoiDung'] ?? map['MaNguoiDung'],
      deThiId: map['deThiId'] ?? map['MaChuong'] ?? 0,
      tenDeThi: map['tenDeThi'] ?? map['TenChuong'],
      diem: (map['diem'] ?? map['Diem'] as num?)?.toDouble() ?? 0,
      soCauDung: map['soCauDung'] ?? map['SoCauDung'] ?? 0,
      soCauSai: map['soCauSai'] ??
          ((map['TongSoCau'] ?? 0) - (map['SoCauDung'] ?? 0)),
      thoiGianLam: map['thoiGianLam'] ?? 0,
      ngayThi: map['ngayThi'] != null
          ? DateTime.parse(map['ngayThi'])
          : DateTime.tryParse(map['NgayLam'] as String? ?? '') ?? DateTime.now(),
      danhSachDapAnChon:
          map['danhSachDapAnChon'] ?? map['DanhSachDapAnChon'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'MaNguoiDung': maNguoiDung,
      'MaChuong': deThiId,
      'Diem': diem,
      'SoCauDung': soCauDung,
      'TongSoCau': soCauDung + soCauSai,
      'DanhSachDapAnChon': danhSachDapAnChon ?? '{}',
      'NgayLam': ngayThi.toIso8601String(),
    };
    // Chỉ thêm id nếu nó không phải null (cho trường hợp update)
    if (id != null) {
      map['MaLichSu'] = id;
    }
    return map;
  }
}
