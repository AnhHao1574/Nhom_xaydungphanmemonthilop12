import '../models/de_thi.dart';
import '../models/cau_hoi.dart';
import 'word_parser_service.dart';
import '../database/database_helper.dart';

class ImportService {
  final WordParserService _wordParserService = WordParserService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<bool> importDeThiTuWord(String filePath, DeThi deThiInfo) async {
    try {
      if (deThiInfo.id == null) return false;

      // 1. Phân tích file Word thành List Câu Hỏi
      List<CauHoi> cauHoiList = await _wordParserService.parseWordFile(filePath, deThiInfo.id!);

      // 2. Chèn từng câu vào cơ sở dữ liệu
      if (cauHoiList.isNotEmpty) {
        for (var cauHoi in cauHoiList) {
          await _db.insertCauHoi(cauHoi);
        }
        print("Đã import thành công ${cauHoiList.length} câu hỏi vào DB.");
        return true;
      }
      return false;
    } catch (e) {
      print("Lỗi Import CSDL: $e");
      return false;
    }
  }
}