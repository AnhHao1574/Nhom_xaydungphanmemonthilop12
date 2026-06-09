import '../database/database_helper.dart';
import '../models/nguoi_dung.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final DatabaseHelper _db = DatabaseHelper.instance;
  NguoiDung? _currentUser;

  NguoiDung? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<String?> login(String tenDangNhap, String matKhau) async {
    if (tenDangNhap.trim().isEmpty || matKhau.isEmpty) {
      return 'Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.';
    }
    final user = await _db.login(tenDangNhap, matKhau);
    if (user == null) {
      return 'Tên đăng nhập hoặc mật khẩu không đúng.';
    }
    _currentUser = user;
    return null;
  }

  Future<String?> register({
    required String tenDangNhap,
    required String matKhau,
    required String xacNhanMatKhau,
    String? hoTen,
    String? email,
  }) async {
    if (tenDangNhap.trim().isEmpty || matKhau.isEmpty) {
      return 'Vui lòng nhập đầy đủ thông tin đăng ký.';
    }
    if (matKhau != xacNhanMatKhau) {
      return 'Mật khẩu xác nhận không khớp.';
    }
    if (matKhau.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự.';
    }
    if (await _db.isTenDangNhapExists(tenDangNhap)) {
      return 'Tên đăng nhập đã tồn tại.';
    }

    final user = NguoiDung(
      tenDangNhap: tenDangNhap.trim(),
      matKhau: matKhau,
      hoTen: hoTen?.trim(),
      email: email?.trim(),
      maVaiTro: 3, // Mặc định là học sinh
    );

    // Lưu tài khoản vào SQLite thành công sẽ nhận về số ID tự tăng
    int insertedId;
    try {
      insertedId = await _db.register(user);
    } catch (e) {
      return "Lỗi đăng ký: $e";
    }
    // 🟢 DÒNG LOG 1: Kiểm tra xem SQLite có thực sự phản hồi và cấp ID mới không
    print(
      "SQLite Register: Đã chèn thành công dòng mới! ID cấp phát = $insertedId",
    );

    // ĐÃ SỬA: Sử dụng đúng thuộc tính 'id' theo đúng Model mới của bạn
    _currentUser = NguoiDung(
      id: insertedId,
      tenDangNhap: user.tenDangNhap,
      matKhau: user.matKhau,
      hoTen: user.hoTen,
      email: user.email,
      maVaiTro: user.maVaiTro,
    );

    // 🟢 DÒNG LOG 2: Kiểm tra xem AuthService đã giữ được phiên đăng nhập của User này chưa
    print(
      "Đăng nhập thẳng thành công! Người dùng hiện tại: ${_currentUser?.tenDangNhap} (ID: ${_currentUser?.id})",
    );

    return null;
  }

  void logout() {
    _currentUser = null;
  }
}
