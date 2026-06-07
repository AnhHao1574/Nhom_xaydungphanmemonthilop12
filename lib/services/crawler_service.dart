import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import '../models/cau_hoi.dart';
import '../database/database_helper.dart';

class CrawlerService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Lấy danh sách câu hỏi từ Vietjack (từ trang 1 đến trang 7) và chèn vào SQLite
  Future<bool> crawlAndImport(int deThiId) async {
    const String baseUrl =
        "https://www.vietjack.com/trac-nghiem-dai-hoc/trac-nghiem-lich-su-viet-nam-hien-dai.jsp";
    List<Map<String, dynamic>> allQuestions = [];

    try {
      for (int page = 1; page <= 7; page++) {
        String url = page == 1 ? baseUrl : "$baseUrl?page=$page";
        // ignore: avoid_print
        print("👉 Đang cào dữ liệu trang $page từ: $url");

        // Thêm .timeout(Duration) để nếu quá 15 giây không tải được sẽ tự động bỏ qua sang trang tiếp, tránh treo app
        final response = await http
            .get(Uri.parse(url), headers: {"User-Agent": "Mozilla/5.0"})
            .timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) {
          // ignore: avoid_print
          print("⚠️ Trang $page phản hồi lỗi: ${response.statusCode}");
          continue;
        }

        var document = parser.parse(response.body);
        List<Element> paragraphs = document.querySelectorAll('p');

        Map<String, dynamic>? current;
        List<Map<String, dynamic>> pageQuestions = [];

        for (var p in paragraphs) {
          String text = p.text.trim();
          if (text.isEmpty) continue;

          if (RegExp(r'Câu\s*\d+').hasMatch(text)) {
            if (current != null) {
              pageQuestions.add(current);
            }
            current = {
              'question': text,
              'answers': <String>[],
              'correct': null,
            };
          } else if (RegExp(r'^[A-D]\.').hasMatch(text)) {
            if (current != null) {
              (current['answers'] as List<String>).add(text);
            }
          } else if (text.contains('Đáp án')) {
            final match = RegExp(r'[A-D]').firstMatch(text);
            if (match != null && current != null) {
              current['correct'] = match.group(0);
            }
          }
        }

        if (current != null) {
          pageQuestions.add(current);
        }

        // ignore: avoid_print
        print("✔ Đã tải xong trang $page. Số câu: ${pageQuestions.length}");
        allQuestions.addAll(pageQuestions);
      }

      // ignore: avoid_print
      print("📊 Tổng câu hỏi cào được: ${allQuestions.length}");

      // Lưu danh sách cào được vào SQLite của Flutter
      int insertedCount = 0;
      for (var q in allQuestions) {
        String questionText = q['question'] as String;
        if (questionText.trim().isEmpty) continue;

        List<String> answers = List<String>.from(q['answers']);
        while (answers.length < 4) {
          answers.add("N/A");
        }

        String cleanAns(String raw) {
          return raw.replaceFirst(RegExp(r'^[A-D]\.\s*'), '').trim();
        }

        await _db.insertCauHoi(
          CauHoi(
            deThiId: deThiId,
            noiDung: questionText,
            dapAnA: cleanAns(answers[0]),
            dapAnB: cleanAns(answers[1]),
            dapAnC: cleanAns(answers[2]),
            dapAnD: cleanAns(answers[3]),
            dapAnDung: q['correct'] ?? "A",
            giaiThich: "Cào tự động từ Vietjack",
          ),
        );

        insertedCount++;
      }

      // ignore: avoid_print
      print("💾 Đã lưu thành công $insertedCount câu hỏi vào CSDL.");
      return true;
    } catch (e) {
      // ignore: avoid_print
      print("❌ Lỗi Cào/Lưu dữ liệu: $e");
      return false;
    }
  }
}
