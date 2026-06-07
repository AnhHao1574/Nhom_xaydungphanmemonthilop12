import 'dart:convert';

import '../database/database_helper.dart';
import '../models/cau_hoi.dart';
import '../models/ket_qua.dart';
import 'auth_service.dart';

class ExamService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<CauHoi>> getCauHoiByDeThi(int deThiId) async {
    return await _db.getCauHoiByDeThi(deThiId);
  }

  KetQua chamDiem({
    required int deThiId,
    required List<CauHoi> danhSachCauHoi,
    required Map<int, String> dapAnHocSinh,
    required int thoiGianLamGiay,
    String? tenDeThi,
  }) {
    int soCauDung = 0;
    int soCauSai = 0;
    final tongSoCau = danhSachCauHoi.length;

    for (final cauHoi in danhSachCauHoi) {
      final chonLuan = dapAnHocSinh[cauHoi.id];
      if (chonLuan != null && chonLuan == cauHoi.dapAnDung) {
        soCauDung++;
      } else {
        soCauSai++;
      }
    }

    final diem = tongSoCau > 0 ? (soCauDung / tongSoCau) * 10 : 0.0;
    final jsonDapAn = jsonEncode({
      'dapAn': dapAnHocSinh.map((k, v) => MapEntry(k.toString(), v)),
      'thoiGianLam': thoiGianLamGiay,
    });

    return KetQua(
      maNguoiDung: AuthService.instance.currentUser?.id,
      deThiId: deThiId,
      tenDeThi: tenDeThi,
      diem: double.parse(diem.toStringAsFixed(2)),
      soCauDung: soCauDung,
      soCauSai: soCauSai,
      thoiGianLam: thoiGianLamGiay,
      ngayThi: DateTime.now(),
      danhSachDapAnChon: jsonDapAn,
    );
  }

  Future<int> luuKetQua(KetQua kq) async {
    return await _db.insertKetQua(kq);
  }

  Future<List<KetQua>> getLichSuThi({int? maNguoiDung}) async {
    if (maNguoiDung != null) {
      return await _db.getKetQuaByUser(maNguoiDung);
    }
    return await _db.getAllKetQua();
  }

  Future<KetQua?> getChiTietLichSu(int id) async {
    return await _db.getKetQuaById(id);
  }
}
