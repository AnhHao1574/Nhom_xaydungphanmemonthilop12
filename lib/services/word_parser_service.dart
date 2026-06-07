import 'package:flutter/services.dart' show rootBundle;
import 'package:docx_to_text/docx_to_text.dart';
import '../models/cau_hoi.dart';
class WordParserService {
  
  // Đọc file Word thật từ thư mục Assets của dự án
  Future<String> _extractTextFromWord(String filePath) async {
    try {
      // 1. Tải dữ liệu thô (ByteData) của file Word từ Assets
      final byteData = await rootBundle.load(filePath);
      
      // 2. Chuyển đổi dữ liệu thô thành mảng các byte (Uint8List)
      final bytes = byteData.buffer.asUint8List();
      
      // 3. Sử dụng thư viện chuyển đổi byte thành chuỗi văn bản thuần (String)
      final text = docxToText(bytes);
      
      return text;
    } catch (e) {
      throw Exception("Không thể đọc file từ Assets: $e");
    }
  }

  /// Hàm phân tích text thành danh sách Câu Hỏi
  Future<List<CauHoi>> parseWordFile(String filePath, int deThiId) async {
    try {
      String rawText = await _extractTextFromWord(filePath);
      List<CauHoi> danhSachCauHoi = [];

      // Regex cơ bản để tìm câu hỏi (Giả định cấu trúc đề chuẩn)
      // Tìm từ "Câu X:" đến "Câu X+1:"
      final questionExp = RegExp(r'(Câu \d+:.*?)(?=Câu \d+:|$)', dotAll: true);
      final matches = questionExp.allMatches(rawText);

      for (var match in matches) {
        String block = match.group(0)?.trim() ?? '';
        
        // Trích xuất nội dung và các đáp án A, B, C, D
        final parts = _splitQuestionBlock(block);
        if (parts != null) {
          danhSachCauHoi.add(CauHoi(
            deThiId: deThiId,
            noiDung: parts['noiDung']!,
            dapAnA: parts['A']!,
            dapAnB: parts['B']!,
            dapAnC: parts['C']!,
            dapAnD: parts['D']!,
            // Mặc định đáp án đúng tạm thời, có thể cờ đánh dấu như [x] hoặc tô đậm trong word
            dapAnDung: 'A', 
            giaiThich: 'Chưa có giải thích',
          ));
        }
      }
      return danhSachCauHoi;
    } catch (e) {
      throw Exception("Lỗi khi đọc file Word: $e");
    }
  }

  Map<String, String>? _splitQuestionBlock(String block) {
    try {
      // Logic tách string. Cần Regex phức tạp hơn tùy thuộc vào form đề thi.
      final noiDung = block.split(RegExp(r'\nA\.'))[0];
      final answerStr = block.substring(noiDung.length);
      
      final answerA = RegExp(r'A\.(.*?)(?=\nB\.)', dotAll: true).firstMatch(answerStr)?.group(1) ?? '';
      final answerB = RegExp(r'B\.(.*?)(?=\nC\.)', dotAll: true).firstMatch(answerStr)?.group(1) ?? '';
      final answerC = RegExp(r'C\.(.*?)(?=\nD\.)', dotAll: true).firstMatch(answerStr)?.group(1) ?? '';
      final answerD = RegExp(r'D\.(.*)', dotAll: true).firstMatch(answerStr)?.group(1) ?? '';

      return {
        'noiDung': noiDung.trim(),
        'A': answerA.trim(),
        'B': answerB.trim(),
        'C': answerC.trim(),
        'D': answerD.trim(),
      };
    } catch (e) {
      return null;
    }
  }
}