import '../models/mon_hoc.dart';
import '../models/de_thi.dart';
import '../models/cau_hoi.dart';
import '../database/database_helper.dart';

class AdminService {
  // Thiết lập Singleton Pattern
  AdminService._privateConstructor();
  static final AdminService instance = AdminService._privateConstructor();
  final DatabaseHelper _db = DatabaseHelper.instance;

  // I. NGHIỆP VỤ CRUD MÔN HỌC (SUBJECTS)
  // 1. CREATE: Thêm mới một môn học
  Future<int> themMonHoc(MonHoc monHoc) async {
    return await _db.insertMonHoc(monHoc);
  }

  // 2. READ: Lấy toàn bộ danh sách môn học
  Future<List<MonHoc>> getDanhSachMonHoc() async {
    return await _db.getAllMonHoc();
  }

  // 2b. READ: Chi tiết một môn học theo ID
  Future<MonHoc?> getChiTietMonHoc(int id) async {
    return await _db.getMonHocById(id);
  }

  // 3. UPDATE: Cập nhật thông tin môn học
  Future<int> capNhatMonHoc(MonHoc monHoc) async {
    return await _db.updateMonHoc(monHoc);
  }

  // 4. DELETE: Xóa môn học theo ID (Sẽ tự động xóa đề thi và câu hỏi liên quan do ON DELETE CASCADE)
  Future<int> xoaMonHoc(int id) async {
    return await _db.deleteMonHoc(id);
  }
  // II. NGHIỆP VỤ CRUD ĐỀ THI (EXAMS)
  // 1. CREATE: Tạo một đề thi mới
  Future<int> themDeThi(DeThi deThi) async {
    return await _db.insertDeThi(deThi);
  }

  // 2. READ: Lấy toàn bộ danh sách đề thi
  Future<List<DeThi>> getDanhSachDeThi() async {
    return await _db.getAllDeThi();
  }

  // 2b. READ: Lấy danh sách đề thi theo môn học cụ thể
  Future<List<DeThi>> getDeThiTheoMonHoc(int monHocId) async {
    return await _db.getDeThiByMonHoc(monHocId);
  }

  // 2c. READ: Chi tiết một đề thi theo ID
  Future<DeThi?> getChiTietDeThi(int id) async {
    return await _db.getDeThiById(id);
  }

  // 3. UPDATE: Cập nhật thông tin đề thi
  Future<int> capNhatDeThi(DeThi deThi) async {
    return await _db.updateDeThi(deThi);
  }
  // 4. DELETE: Xóa đề thi theo ID
  Future<int> xoaDeThi(int id) async {
    return await _db.deleteDeThi(id);
  }

  // III. NGHIỆP VỤ CRUD CÂU HỎI (QUESTIONS)
  // 1. CREATE: Thêm một câu hỏi đơn lẻ thủ công
  Future<int> themCauHoi(CauHoi cauHoi) async {
    return await _db.insertCauHoi(cauHoi);
  }

  // 2. READ: Lấy toàn bộ câu hỏi của một đề thi cụ thể
  Future<List<CauHoi>> getCauHoiTheoDeThi(int deThiId) async {
    return await _db.getCauHoiByDeThi(deThiId);
  }

  // 2b. READ: Lấy chi tiết câu hỏi theo ID
  Future<CauHoi?> getChiTietCauHoi(int id) async {
    return await _db.getCauHoiById(id);
  }

  // 3. UPDATE: Sửa nội dung câu hỏi hoặc đáp án
  Future<int> capNhatCauHoi(CauHoi cauHoi) async {
    return await _db.updateCauHoi(cauHoi);
  }

  // 4. DELETE: Xóa một câu hỏi cụ thể theo ID
  Future<int> xoaCauHoi(int id) async {
    return await _db.deleteCauHoi(id);
  }
}