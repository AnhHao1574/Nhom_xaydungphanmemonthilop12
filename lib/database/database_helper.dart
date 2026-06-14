// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_7/main.dart';
import 'package:http/http.dart' as http;

import '../models/cau_hoi.dart';
import '../models/de_thi.dart';
import '../models/ket_qua.dart';
import '../models/mon_hoc.dart';
import '../models/nguoi_dung.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Địa chỉ IP của máy tính chạy backend API.
  // - Nếu dùng điện thoại thật: nhập IP của máy tính (Hiện tại là: '192.168.1.165').
  // - Nếu dùng máy ảo Android (Emulator): có thể dùng '10.0.2.2' hoặc IP máy tính.
  // - Lưu ý: Điện thoại thật và máy tính cần kết nối chung một mạng Wi-Fi.
  static const String serverIp = '192.168.1.165';

  static final String baseUrl = Platform.isAndroid
      ? 'http://$serverIp:5094/api'
      : 'http://localhost:5094/api';

  // Getter giả lập cho database để không làm lỗi file main.dart
  Future<dynamic> get database async {
    return Future.value(null);
  }

  // Headers mặc định cho các yêu cầu gửi dữ liệu dạng JSON
  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  // Giải mã response body bằng UTF-8 để hiển thị đúng tiếng Việt có dấu
  String _decode(http.Response response) => utf8.decode(response.bodyBytes);

  // Hiển thị thông báo lỗi tức thì khi mất kết nối SQL hoặc máy chủ API
  void _showErrorNotification(String message) {
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Wrapper cho http.get với timeout và xử lý lỗi ngắt kết nối SQL/API
  Future<http.Response> _get(Uri url, {Map<String, String>? headers}) async {
    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 3));
      if (response.statusCode >= 500) {
        _showErrorNotification(
          'Lỗi máy chủ hoặc mất kết nối cơ sở dữ liệu SQL Server!',
        );
      }
      return response;
    } on SocketException catch (_) {
      _showErrorNotification(
        'Không thể kết nối đến API backend! Vui lòng kiểm tra backend.',
      );
      rethrow;
    } on TimeoutException catch (_) {
      _showErrorNotification(
        'Kết nối quá hạn (Timeout)! Vui lòng chờ kết nối.',
      );
      rethrow;
    } catch (e) {
      _showErrorNotification('Lỗi kết nối: $e');
      rethrow;
    }
  }

  // Wrapper cho http.post với timeout và xử lý lỗi ngắt kết nối SQL/API
  Future<http.Response> _post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    try {
      final response = await http
          .post(url, headers: headers, body: body, encoding: encoding)
          .timeout(const Duration(seconds: 3));
      if (response.statusCode >= 500) {
        _showErrorNotification(
          'Lỗi máy chủ hoặc mất kết nối cơ sở dữ liệu SQL Server!',
        );
      }
      return response;
    } on SocketException catch (_) {
      _showErrorNotification(
        'Không thể kết nối đến API backend! Vui lòng kiểm tra backend.',
      );
      rethrow;
    } on TimeoutException catch (_) {
      _showErrorNotification(
        'Kết nối quá hạn (Timeout)! Vui lòng chờ kết nối.',
      );
      rethrow;
    } catch (e) {
      _showErrorNotification('Lỗi kết nối: $e');
      rethrow;
    }
  }

  // Wrapper cho http.put với timeout và xử lý lỗi ngắt kết nối SQL/API
  Future<http.Response> _put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    try {
      final response = await http
          .put(url, headers: headers, body: body, encoding: encoding)
          .timeout(const Duration(seconds: 3));
      if (response.statusCode >= 500) {
        _showErrorNotification(
          'Lỗi máy chủ hoặc mất kết nối cơ sở dữ liệu SQL Server!',
        );
      }
      return response;
    } on SocketException catch (_) {
      _showErrorNotification(
        'Không thể kết nối đến API backend! Vui lòng kiểm tra backend.',
      );
      rethrow;
    } on TimeoutException catch (_) {
      _showErrorNotification(
        'Kết nối quá hạn (Timeout)! Vui lòng chờ kết nối.',
      );
      rethrow;
    } catch (e) {
      _showErrorNotification('Lỗi kết nối: $e');
      rethrow;
    }
  }

  // Wrapper cho http.delete với timeout và xử lý lỗi ngắt kết nối SQL/API
  Future<http.Response> _delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    try {
      final response = await http
          .delete(url, headers: headers, body: body, encoding: encoding)
          .timeout(const Duration(seconds: 3));
      if (response.statusCode >= 500) {
        _showErrorNotification(
          'Lỗi máy chủ hoặc mất kết nối cơ sở dữ liệu SQL Server!',
        );
      }
      return response;
    } on SocketException catch (_) {
      _showErrorNotification(
        'Không thể kết nối đến API backend! Vui lòng kiểm tra backend.',
      );
      rethrow;
    } on TimeoutException catch (_) {
      _showErrorNotification(
        'Kết nối quá hạn (Timeout)! Vui lòng chờ kết nối.',
      );
      rethrow;
    } catch (e) {
      _showErrorNotification('Lỗi kết nối: $e');
      rethrow;
    }
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
      diem: (row['Diem'] as num?)?.toDouble() ?? 0.0,
      soCauDung: soCauDung,
      soCauSai: tongSoCau - soCauDung,
      thoiGianLam: _parseThoiGianFromJson(row['DanhSachDapAnChon'] as String?),
      ngayThi:
          DateTime.tryParse(row['NgayLam'] as String? ?? '') ?? DateTime.now(),
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
    try {
      final response = await _post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'TenDangNhap': tenDangNhap.trim(),
          'MatKhau': matKhau,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(_decode(response));
        return NguoiDung.fromMap(data);
      }
    } catch (e) {
      print('Lỗi kết nối API login: $e');
    }
    return null;
  }

  Future<bool> isTenDangNhapExists(String tenDangNhap) async {
    try {
      final response = await _get(
        Uri.parse(
          '$baseUrl/auth/check-username?tenDangNhap=${Uri.encodeComponent(tenDangNhap.trim())}',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(_decode(response)) as bool;
      }
    } catch (e) {
      print('Lỗi kết nối API check-username: $e');
    }
    return false;
  }

  Future<int> register(NguoiDung user) async {
    try {
      // Ánh xạ chuẩn xác cấu trúc bảng NguoiDung của SQL Server backend
      final Map<String, dynamic> requestBody = {
        'TenDangNhap': user.tenDangNhap.trim(),
        'MatKhau': user.matKhau,
        'HoTen': user.hoTen,
        'Email': user.email,
        'MaVaiTro': user.maVaiTro,
      };

      final response = await _post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(_decode(response));
        return data['MaNguoiDung'] as int? ?? 0;
      }
    } catch (e) {
      print('Lỗi kết nối API register: $e');
    }
    return 0;
  }

  // ================= QUẢN LÝ MÔN HỌC =================
  Future<int> insertMonHoc(MonHoc monHoc) async {
    try {
      final response = await _post(
        Uri.parse('$baseUrl/monhoc'),
        headers: _headers,
        body: jsonEncode(_monHocToRow(monHoc)),
      );
      if (response.statusCode == 200) {
        return jsonDecode(_decode(response)) as int;
      }
    } catch (e) {
      print('Lỗi kết nối API insertMonHoc: $e');
    }
    return 0;
  }

  Future<List<MonHoc>> getAllMonHoc() async {
    try {
      final response = await _get(
        Uri.parse('$baseUrl/monhoc'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> listJson = jsonDecode(_decode(response));
        return listJson
            .map((item) => _monHocFromRow(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Lỗi kết nối API getAllMonHoc: $e');
    }
    return [];
  }

  Future<MonHoc?> getMonHocById(int id) async {
    try {
      final response = await _get(
        Uri.parse('$baseUrl/monhoc/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(_decode(response));
        return _monHocFromRow(data);
      }
    } catch (e) {
      print('Lỗi kết nối API getMonHocById: $e');
    }
    return null;
  }

  Future<int> updateMonHoc(MonHoc monHoc) async {
    if (monHoc.id == null) return 0;
    try {
      final response = await _put(
        Uri.parse('$baseUrl/monhoc/${monHoc.id}'),
        headers: _headers,
        body: jsonEncode(_monHocToRow(monHoc)),
      );
      if (response.statusCode == 200) {
        return jsonDecode(_decode(response)) as int;
      }
    } catch (e) {
      print('Lỗi kết nối API updateMonHoc: $e');
    }
    return 0;
  }

  Future<int> deleteMonHoc(int id) async {
    try {
      final response = await _delete(
        Uri.parse('$baseUrl/monhoc/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(_decode(response)) as int;
      }
    } catch (e) {
      print('Lỗi kết nối API deleteMonHoc: $e');
    }
    return 0;
  }

  // ================= QUẢN LÝ ĐỀ THI (Chuong) =================
  Future<int> insertDeThi(DeThi deThi) async {
    try {
      final Map<String, dynamic> requestBody = {
        'MaMon': deThi.monHocId,
        'TenChuong': deThi.tenDe,
        'SoThuTu': deThi.soThuTu,
      };

      final response = await _post(
        Uri.parse('$baseUrl/chuong'),
        headers: _headers,
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        return jsonDecode(_decode(response)) as int;
      }
    } catch (e) {
      print('Lỗi kết nối API insertDeThi: $e');
    }
    return 0;
  }

  Future<List<DeThi>> getAllDeThi() async {
    try {
      final response = await _get(
        Uri.parse('$baseUrl/chuong'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> listJson = jsonDecode(_decode(response));
        return listJson
            .map((item) => _deThiFromRow(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Lỗi kết nối API getAllDeThi: $e');
    }
    return [];
  }

  Future<DeThi?> getDeThiById(int id) async {
    try {
      final response = await _get(
        Uri.parse('$baseUrl/chuong/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(_decode(response));
        return _deThiFromRow(data);
      }
    } catch (e) {
      print('Lỗi kết nối API getDeThiById: $e');
    }
    return null;
  }

  Future<List<DeThi>> getDeThiByMonHoc(int monHocId) async {
    try {
      final response = await _get(
        Uri.parse('$baseUrl/chuong/monhoc/$monHocId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> listJson = jsonDecode(_decode(response));
        return listJson
            .map((item) => _deThiFromRow(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Lỗi kết nối API getDeThiByMonHoc: $e');
    }
    return [];
  }

  Future<int> updateDeThi(DeThi deThi) async {
    if (deThi.id == null) return 0;
    try {
      final Map<String, dynamic> requestBody = {
        'MaMon': deThi.monHocId,
        'TenChuong': deThi.tenDe,
        'SoThuTu': deThi.soThuTu,
      };

      final response = await _put(
        Uri.parse('$baseUrl/chuong/${deThi.id}'),
        headers: _headers,
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        return jsonDecode(_decode(response)) as int;
      }
    } catch (e) {
      print('Lỗi kết nối API updateDeThi: $e');
    }
    return 0;
  }

  Future<int> deleteDeThi(int id) async {
    try {
      final response = await _delete(
        Uri.parse('$baseUrl/chuong/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(_decode(response)) as int;
      }
    } catch (e) {
      print('Lỗi kết nối API deleteDeThi: $e');
    }
    return 0;
  }

  // ================= QUẢN LÝ CÂU HỎI =================
  Future<int> insertCauHoi(CauHoi cauHoi) async {
    try {
      final response = await _post(
        Uri.parse('$baseUrl/cauhoi'),
        headers: _headers,
        body: jsonEncode(_cauHoiToRow(cauHoi)),
      );
      if (response.statusCode == 200) {
        return jsonDecode(_decode(response)) as int;
      }
    } catch (e) {
      print('Lỗi kết nối API insertCauHoi: $e');
    }
    return 0;
  }

  Future<List<CauHoi>> getCauHoiByDeThi(int deThiId) async {
    try {
      final response = await _get(
        Uri.parse('$baseUrl/cauhoi/dethi/$deThiId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> listJson = jsonDecode(_decode(response));
        return listJson
            .map((item) => _cauHoiFromRow(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Lỗi kết nối API getCauHoiByDeThi: $e');
    }
    return [];
  }

  Future<List<CauHoi>> getAllCauHoi() async {
    try {
      final response = await _get(
        Uri.parse('$baseUrl/cauhoi'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> listJson = jsonDecode(_decode(response));
        return listJson
            .map((item) => _cauHoiFromRow(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Lỗi kết nối API getAllCauHoi: $e');
    }
    return [];
  }

  Future<CauHoi?> getCauHoiById(int id) async {
    try {
      final response = await _get(
        Uri.parse('$baseUrl/cauhoi/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(_decode(response));
        return _cauHoiFromRow(data);
      }
    } catch (e) {
      print('Lỗi kết nối API getCauHoiById: $e');
    }
    return null;
  }

  Future<int> updateCauHoi(CauHoi cauHoi) async {
    if (cauHoi.id == null) return 0;
    try {
      final response = await _put(
        Uri.parse('$baseUrl/cauhoi/${cauHoi.id}'),
        headers: _headers,
        body: jsonEncode(_cauHoiToRow(cauHoi)),
      );
      if (response.statusCode == 200) {
        return jsonDecode(_decode(response)) as int;
      }
    } catch (e) {
      print('Lỗi kết nối API updateCauHoi: $e');
    }
    return 0;
  }

  Future<int> deleteCauHoi(int id) async {
    try {
      final response = await _delete(
        Uri.parse('$baseUrl/cauhoi/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(_decode(response)) as int;
      }
    } catch (e) {
      print('Lỗi kết nối API deleteCauHoi: $e');
    }
    return 0;
  }

  // ================= QUẢN LÝ KẾT QUẢ (LichSuLamBai) =================
  Future<int> insertKetQua(KetQua ketQua) async {
    try {
      final response = await _post(
        Uri.parse('$baseUrl/lichsulambai'),
        headers: _headers,
        body: jsonEncode(ketQua.toMap()),
      );
      if (response.statusCode == 200) {
        return jsonDecode(_decode(response)) as int;
      }
    } catch (e) {
      print('Lỗi kết nối API insertKetQua: $e');
    }
    return 0;
  }

  Future<List<KetQua>> getAllKetQua() async {
    try {
      final response = await _get(
        Uri.parse('$baseUrl/lichsulambai'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> listJson = jsonDecode(_decode(response));
        return listJson
            .map((item) => _ketQuaFromRow(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Lỗi kết nối API getAllKetQua: $e');
    }
    return [];
  }

  Future<List<KetQua>> getKetQuaByUser(int maNguoiDung) async {
    try {
      final response = await _get(
        Uri.parse('$baseUrl/lichsulambai/user/$maNguoiDung'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> listJson = jsonDecode(_decode(response));
        return listJson
            .map((item) => _ketQuaFromRow(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Lỗi kết nối API getKetQuaByUser: $e');
    }
    return [];
  }

  Future<KetQua?> getKetQuaById(int id) async {
    try {
      final response = await _get(
        Uri.parse('$baseUrl/lichsulambai/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(_decode(response));
        return _ketQuaFromRow(data);
      }
    } catch (e) {
      print('Lỗi kết nối API getKetQuaById: $e');
    }
    return null;
  }
}
