import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import '../models/cau_hoi.dart';
import '../database/database_helper.dart';

class CrawlerService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Cào câu hỏi trắc nghiệm từ Vietjack hoặc detracnghiem.edu.vn và chèn vào database
  Future<bool> crawlAndImport(int deThiId, String targetUrl, {int maxPages = 5}) async {
    try {
      if (targetUrl.contains("detracnghiem.edu.vn")) {
        return await _crawlAndImportDeTracNghiem(deThiId, targetUrl);
      } else {
        return await _crawlAndImportVietJack(deThiId, targetUrl, maxPages: maxPages);
      }
    } catch (e) {
      // ignore: avoid_print
      print("❌ Lỗi Cào/Lưu dữ liệu tổng quát: $e");
      return false;
    }
  }

  // Cào từ detracnghiem.edu.vn
  Future<bool> _crawlAndImportDeTracNghiem(int deThiId, String targetUrl) async {
    // ignore: avoid_print
    print("👉 Đang cào dữ liệu từ detracnghiem.edu.vn: $targetUrl");

    final response = await http
        .get(Uri.parse(targetUrl), headers: {"User-Agent": "Mozilla/5.0"})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      // ignore: avoid_print
      print("⚠️ Phản hồi lỗi từ detracnghiem.edu.vn: ${response.statusCode}");
      return false;
    }

    var document = parser.parse(response.body);
    List<Element> paragraphs = document.querySelectorAll('p');
    List<Map<String, dynamic>> questions = [];

    for (var p in paragraphs) {
      String text = p.text.trim();
      if (text.isEmpty) continue;
      
      // Kiểm tra có phải dòng bắt đầu bằng "Câu X" hay không
      if (!text.startsWith('Câu') && !RegExp(r'^Câu\s*\d+').hasMatch(text)) {
        continue;
      }

      String noiDung = "";
      List<String> options = [];
      String dapAnDung = "A";

      for (var node in p.nodes) {
        if (node.nodeType == Node.TEXT_NODE) {
          String val = node.text?.trim() ?? "";
          if (val.isEmpty) continue;

          if (RegExp(r'^[A-D]\.').hasMatch(val)) {
            options.add(val);
          } else {
            if (options.isEmpty) {
              if (noiDung.isNotEmpty) noiDung += " ";
              noiDung += val;
            }
          }
        } else if (node.nodeType == Node.ELEMENT_NODE) {
          Element el = node as Element;
          String val = el.text.trim();
          
          if (el.localName == 'strong' && val.isNotEmpty) {
            if (RegExp(r'^[A-D]\.').hasMatch(val)) {
              options.add(val);
              final match = RegExp(r'^([A-D])\.').firstMatch(val);
              if (match != null) {
                dapAnDung = match.group(1)!;
              }
            } else {
              if (options.isEmpty) {
                if (noiDung.isNotEmpty) noiDung += " ";
                noiDung += val;
              }
            }
          } else if (el.localName != 'br') {
            if (val.isNotEmpty) {
              if (RegExp(r'^[A-D]\.').hasMatch(val)) {
                options.add(val);
              } else if (options.isEmpty) {
                if (noiDung.isNotEmpty) noiDung += " ";
                noiDung += val;
              }
            }
          }
        }
      }

      if (options.length >= 2) {
        questions.add({
          'question': noiDung,
          'answers': options,
          'correct': dapAnDung,
        });
      }
    }

    // ignore: avoid_print
    print("📊 Cào được ${questions.length} câu hỏi từ detracnghiem.edu.vn");

    int insertedCount = 0;
    for (var q in questions) {
      String questionText = q['question'] as String;
      if (questionText.trim().isEmpty) continue;

      List<String> answers = List<String>.from(q['answers']);
      while (answers.length < 4) {
        answers.add("N/A");
      }

      String cleanAns(String raw) {
        return raw.replaceFirst(RegExp(r'^[A-D]\.\s*'), '').trim();
      }

      final insertId = await _db.insertCauHoi(
        CauHoi(
          deThiId: deThiId,
          noiDung: questionText,
          dapAnA: cleanAns(answers[0]),
          dapAnB: cleanAns(answers[1]),
          dapAnC: cleanAns(answers[2]),
          dapAnD: cleanAns(answers[3]),
          dapAnDung: q['correct'] ?? "A",
          giaiThich: "Cào tự động từ detracnghiem.edu.vn",
        ),
      );

      if (insertId == 0) {
        // Nếu chèn thất bại (do lỗi kết nối database/API), dừng ngay để tránh treo ứng dụng lâu
        // ignore: avoid_print
        print("⚠️ Lỗi lưu câu hỏi. Dừng tiến trình cào.");
        break;
      }
      
      insertedCount++;
    }

    // ignore: avoid_print
    print("💾 Đã lưu thành công $insertedCount câu hỏi từ detracnghiem.edu.vn vào CSDL.");
    return insertedCount > 0;
  }

  // Cào từ Vietjack
  Future<bool> _crawlAndImportVietJack(int deThiId, String targetUrl, {int maxPages = 5}) async {
    List<Map<String, dynamic>> allQuestions = [];

    for (int page = 1; page <= maxPages; page++) {
      String url = page == 1 ? targetUrl : "$targetUrl?page=$page";
      // ignore: avoid_print
      print("👉 Đang cào dữ liệu trang $page từ: $url");

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
    print("📊 Tổng câu hỏi cào từ VietJack: ${allQuestions.length}");

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

      final insertId = await _db.insertCauHoi(
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

      if (insertId == 0) {
        // ignore: avoid_print
        print("⚠️ Lỗi lưu câu hỏi. Dừng tiến trình cào.");
        break;
      }
      
      insertedCount++;
    }

    // ignore: avoid_print
    print("💾 Đã lưu thành công $insertedCount câu hỏi VietJack vào CSDL.");
    return insertedCount > 0;
  }
}
