import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cau_hoi.dart';
import '../models/de_thi.dart';
import '../models/ket_qua.dart';
import '../models/mon_hoc.dart';
import '../models/nguoi_dung.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static const _dbName = 'questions.db';
  static const _assetPath = 'assets/database/questions.db';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    if (!await databaseExists(path)) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}
      final data = await rootBundle.load(_assetPath);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  MonHoc _monHocFromRow(Map<String, dynamic> row) {
    final id = row['MaMon'] as int;
    return MonHoc(
      id: id,
      maMon: 'MH$id',
      tenMon: row['TenMon'] as String? ?? '',
      moTa: row['MoTa'] as String?,
    );
  }

  Map<String, dynamic> _monHocToRow(MonHoc monHoc) => {
        if (monHoc.id != null) 'MaMon': monHoc.id,
        'TenMon': monHoc.tenMon,
        'MoTa': monHoc.moTa,
      };

  DeThi _deThiFromRow(Map<String, dynamic> row) {
    final id = row['MaChuong'] as int;
    final soThuTu = row['SoThuTu'] as int? ?? id;
    return DeThi(
      id: id,
      monHocId: row['MaMon'] as int? ?? 0,
      maDe: 'CH$soThuTu',
      tenDe: row['TenChuong'] as String? ?? '',
      thoiGian: 45,
      namThi: DateTime.now().year,
      soThuTu: soThuTu,
    );
  }

  CauHoi _cauHoiFromRow(Map<String, dynamic> row) => CauHoi(
        id: row['MaCauHoi'] as int?,
        deThiId: row['MaChuong'] as int? ?? 0,
        noiDung: row['NoiDung'] as String? ?? '',
        dapAnA: row['CauA'] as String? ?? '',
        dapAnB: row['CauB'] as String? ?? '',
        dapAnC: row['CauC'] as String? ?? '',
        dapAnD: row['CauD'] as String? ?? '',
        dapAnDung: row['DapAnDung'] as String? ?? '',
        giaiThich: row['LoiGiai'] as String?,
      );

  Map<String, dynamic> _cauHoiToRow(CauHoi cauHoi) => {
        if (cauHoi.id != null) 'MaCauHoi': cauHoi.id,
        'MaChuong': cauHoi.deThiId,
        'NoiDung': cauHoi.noiDung,
        'CauA': cauHoi.dapAnA,
        'CauB': cauHoi.dapAnB,
        'CauC': cauHoi.dapAnC,
        'CauD': cauHoi.dapAnD,
        'DapAnDung': cauHoi.dapAnDung,
        'LoiGiai': cauHoi.giaiThich,
        'NgayTao': DateTime.now().toIso8601String(),
      };

  KetQua _ketQuaFromRow(Map<String, dynamic> row) {
    final tongSoCau = row['TongSoCau'] as int? ?? 0;
    final soCauDung = row['SoCauDung'] as int? ?? 0;
    return KetQua(
      id: row['MaLichSu'] as int?,
      maNguoiDung: row['MaNguoiDung'] as int?,
      deThiId: row['MaChuong'] as int? ?? 0,
      tenDeThi: row['TenChuong'] as String?,
      diem: (row['Diem'] as num?)?.toDouble() ?? 0,
      soCauDung: soCauDung,
      soCauSai: tongSoCau - soCauDung,
      thoiGianLam: _parseThoiGianFromJson(row['DanhSachDapAnChon'] as String?),
      ngayThi: DateTime.tryParse(row['NgayLam'] as String? ?? '') ??
          DateTime.now(),
      danhSachDapAnChon: row['DanhSachDapAnChon'] as String?,
    );
  }

  int _parseThoiGianFromJson(String? json) {
    if (json == null || json.isEmpty) return 0;
    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return decoded['thoiGianLam'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ================= XÁC THỰC NGƯỜI DÙNG =================
  Future<NguoiDung?> login(String tenDangNhap, String matKhau) async {
    final db = await database;
    final result = await db.query(
      'NguoiDung',
      where: 'TenDangNhap = ? AND MatKhau = ?',
      whereArgs: [tenDangNhap.trim(), matKhau],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return NguoiDung.fromMap(result.first);
  }

  Future<bool> isTenDangNhapExists(String tenDangNhap) async {
    final db = await database;
    final result = await db.query(
      'NguoiDung',
      where: 'TenDangNhap = ?',
      whereArgs: [tenDangNhap.trim()],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> register(NguoiDung user) async {
    final db = await database;
    return await db.insert('NguoiDung', user.toMap());
  }

  // ================= QUẢN LÝ MÔN HỌC =================
  Future<int> insertMonHoc(MonHoc monHoc) async {
    final db = await database;
    return await db.insert('MonHoc', _monHocToRow(monHoc));
  }

  Future<List<MonHoc>> getAllMonHoc() async {
    final db = await database;
    final result = await db.query('MonHoc', orderBy: 'MaMon ASC');
    return result.map(_monHocFromRow).toList();
  }

  Future<MonHoc?> getMonHocById(int id) async {
    final db = await database;
    final maps = await db.query(
      'MonHoc',
      where: 'MaMon = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return _monHocFromRow(maps.first);
    return null;
  }

  Future<int> updateMonHoc(MonHoc monHoc) async {
    final db = await database;
    return await db.update(
      'MonHoc',
      _monHocToRow(monHoc),
      where: 'MaMon = ?',
      whereArgs: [monHoc.id],
    );
  }

  Future<int> deleteMonHoc(int id) async {
    final db = await database;
    final chuongs = await db.query(
      'Chuong',
      columns: ['MaChuong'],
      where: 'MaMon = ?',
      whereArgs: [id],
    );
    for (final ch in chuongs) {
      await deleteDeThi(ch['MaChuong'] as int);
    }
    return await db.delete('MonHoc', where: 'MaMon = ?', whereArgs: [id]);
  }

  // ================= QUẢN LÝ ĐỀ THI (Chuong) =================
  Future<int> insertDeThi(DeThi deThi) async {
    final db = await database;
    int soThuTu = deThi.soThuTu ?? 0;
    if (soThuTu <= 0) {
      final maxResult = await db.rawQuery(
        'SELECT MAX(SoThuTu) as maxStt FROM Chuong WHERE MaMon = ?',
        [deThi.monHocId],
      );
      soThuTu = (maxResult.first['maxStt'] as int? ?? 0) + 1;
    }

    return await db.insert('Chuong', {
      'MaMon': deThi.monHocId,
      'TenChuong': deThi.tenDe,
      'SoThuTu': soThuTu,
    });
  }

  Future<List<DeThi>> getAllDeThi() async {
    final db = await database;
    final result = await db.query('Chuong', orderBy: 'MaChuong DESC');
    return result.map(_deThiFromRow).toList();
  }

  Future<DeThi?> getDeThiById(int id) async {
    final db = await database;
    final maps = await db.query(
      'Chuong',
      where: 'MaChuong = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return _deThiFromRow(maps.first);
    return null;
  }

  Future<List<DeThi>> getDeThiByMonHoc(int monHocId) async {
    final db = await database;
    final result = await db.query(
      'Chuong',
      where: 'MaMon = ?',
      whereArgs: [monHocId],
      orderBy: 'SoThuTu ASC',
    );
    return result.map(_deThiFromRow).toList();
  }

  Future<int> updateDeThi(DeThi deThi) async {
    final db = await database;
    return await db.update(
      'Chuong',
      {
        'MaMon': deThi.monHocId,
        'TenChuong': deThi.tenDe,
        if (deThi.soThuTu != null) 'SoThuTu': deThi.soThuTu,
      },
      where: 'MaChuong = ?',
      whereArgs: [deThi.id],
    );
  }

  Future<int> deleteDeThi(int id) async {
    final db = await database;
    await db.delete('CauHoi', where: 'MaChuong = ?', whereArgs: [id]);
    await db.delete('LichSuLamBai', where: 'MaChuong = ?', whereArgs: [id]);
    return await db.delete('Chuong', where: 'MaChuong = ?', whereArgs: [id]);
  }

  // ================= QUẢN LÝ CÂU HỎI =================
  Future<int> insertCauHoi(CauHoi cauHoi) async {
    final db = await database;
    return await db.insert('CauHoi', _cauHoiToRow(cauHoi));
  }

  Future<List<CauHoi>> getCauHoiByDeThi(int deThiId) async {
    final db = await database;
    final result = await db.query(
      'CauHoi',
      where: 'MaChuong = ?',
      whereArgs: [deThiId],
      orderBy: 'MaCauHoi ASC',
    );
    return result.map(_cauHoiFromRow).toList();
  }

  Future<List<CauHoi>> getAllCauHoi() async {
    final db = await database;
    final result = await db.query('CauHoi', orderBy: 'MaCauHoi DESC');
    return result.map(_cauHoiFromRow).toList();
  }

  Future<CauHoi?> getCauHoiById(int id) async {
    final db = await database;
    final maps = await db.query(
      'CauHoi',
      where: 'MaCauHoi = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return _cauHoiFromRow(maps.first);
    return null;
  }

  Future<int> updateCauHoi(CauHoi cauHoi) async {
    final db = await database;
    return await db.update(
      'CauHoi',
      _cauHoiToRow(cauHoi),
      where: 'MaCauHoi = ?',
      whereArgs: [cauHoi.id],
    );
  }

  Future<int> deleteCauHoi(int id) async {
    final db = await database;
    return await db.delete(
      'CauHoi',
      where: 'MaCauHoi = ?',
      whereArgs: [id],
    );
  }

  // ================= QUẢN LÝ KẾT QUẢ (LichSuLamBai) =================
  Future<int> insertKetQua(KetQua ketQua) async {
    final db = await database;
    return await db.insert('LichSuLamBai', ketQua.toMap());
  }

  Future<List<KetQua>> getAllKetQua() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT ls.*, c.TenChuong
      FROM LichSuLamBai ls
      LEFT JOIN Chuong c ON ls.MaChuong = c.MaChuong
      ORDER BY ls.NgayLam DESC
    ''');
    return result.map(_ketQuaFromRow).toList();
  }

  Future<List<KetQua>> getKetQuaByUser(int maNguoiDung) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT ls.*, c.TenChuong
      FROM LichSuLamBai ls
      LEFT JOIN Chuong c ON ls.MaChuong = c.MaChuong
      WHERE ls.MaNguoiDung = ?
      ORDER BY ls.NgayLam DESC
    ''', [maNguoiDung]);
    return result.map(_ketQuaFromRow).toList();
  }

  Future<KetQua?> getKetQuaById(int id) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT ls.*, c.TenChuong
      FROM LichSuLamBai ls
      LEFT JOIN Chuong c ON ls.MaChuong = c.MaChuong
      WHERE ls.MaLichSu = ?
    ''', [id]);
    if (result.isEmpty) return null;
    return _ketQuaFromRow(result.first);
  }
}
