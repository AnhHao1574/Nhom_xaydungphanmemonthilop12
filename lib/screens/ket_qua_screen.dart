import 'package:flutter/material.dart';
import '../models/ket_qua.dart';

class KetQuaScreen extends StatelessWidget {
  final KetQua ketQua;

  // Sử dụng super.key chuẩn hóa cho các phiên bản Flutter mới
  const KetQuaScreen({super.key, required this.ketQua});

  // Hàm phụ trợ để định dạng lại thời gian làm bài (từ giây sang mm:ss)
  String _formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Nhận xét dựa trên điểm số
  String _getFeedback(double score) {
    if (score >= 8.0) return 'Xuất sắc! Cố gắng phát huy nhé! 🎉';
    if (score >= 6.5) return 'Khá tốt! Chăm chỉ hơn nữa để đạt điểm cao nhé! 👍';
    if (score >= 5.0) return 'Đạt yêu cầu. Cần ôn tập kỹ hơn các phần bị sai! 📚';
    return 'Cần cố gắng nhiều hơn! Đừng nản chí nhé! 💪';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết Quả Bài Thi'),
        automaticallyImplyLeading: false, // Ẩn nút quay lại để tránh học sinh ấn back quay lại làm tiếp
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon thông báo kết quả
              Icon(
                ketQua.diem >= 5.0 ? Icons.check_circle_outline : Icons.sentiment_dissatisfied,
                size: 80,
                color: ketQua.diem >= 5.0 ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 16),

              // Dòng chữ "Điểm số"
              const Text(
                'ĐIỂM SỐ CỦA BẠN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),

              // Điểm số lớn
              Text(
                ketQua.diem.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: ketQua.diem >= 8.0
                      ? Colors.green
                      : (ketQua.diem >= 5.0 ? Colors.blue : Colors.red),
                ),
              ),
              const SizedBox(height: 12),

              // Lời nhận xét động
              Text(
                _getFeedback(ketQua.diem),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),

              // Bảng thông tin chi tiết
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildResultRow(
                        icon: Icons.check_circle,
                        color: Colors.green,
                        label: 'Số câu trả lời đúng:',
                        value: '${ketQua.soCauDung} câu',
                      ),
                      const Divider(),
                      _buildResultRow(
                        icon: Icons.cancel,
                        color: Colors.red,
                        label: 'Số câu trả lời sai:',
                        value: '${ketQua.soCauSai} câu',
                      ),
                      const Divider(),
                      _buildResultRow(
                        icon: Icons.timer,
                        color: Colors.blueGrey,
                        label: 'Thời gian làm bài:',
                        value: _formatDuration(ketQua.thoiGianLam),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Nút quay về trang chủ
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Xóa hết các màn hình trong stack và quay về màn đầu tiên (HomeScreen)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text(
                    'QUAY VỀ TRANG CHỦ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm tạo dòng thông tin chi tiết
  Widget _buildResultRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}