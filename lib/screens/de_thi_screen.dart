import 'package:flutter/material.dart';
import '../models/de_thi.dart';
import 'lam_bai_screen.dart';
import '../services/exam_service.dart';
import '../models/cau_hoi.dart';

class DeThiScreen extends StatelessWidget {
  final DeThi deThi;
  final List<Color>? gradientColors;

  const DeThiScreen({
    super.key,
    required this.deThi,
    this.gradientColors,
  });

  String _getSubjectName(int id) {
    switch (id) {
      case 1:
        return 'Hóa Học';
      case 2:
        return 'Toán Học';
      case 3:
        return 'Vật Lý 12';
      case 4:
        return 'Lịch Sử 12';
      default:
        return 'Môn học khác';
    }
  }

  IconData _getSubjectIcon(int id) {
    switch (id) {
      case 1:
        return Icons.science;
      case 2:
        return Icons.calculate;
      case 3:
        return Icons.bolt;
      case 4:
        return Icons.history_edu;
      default:
        return Icons.book;
    }
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color themeColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 22,
            color: themeColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF78909C),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF37474F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? [const Color(0xFF1565C0), const Color(0xFF1E88E5)];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Chi tiết đề thi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colors[0],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Gradient header card
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),
          // Content overlay
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Icon badge
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: colors[0].withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getSubjectIcon(deThi.monHocId),
                              size: 50,
                              color: colors[0],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Subject badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colors[0].withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getSubjectName(deThi.monHocId).toUpperCase(),
                              style: TextStyle(
                                color: colors[0],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Exam Name
                          Text(
                            deThi.tenDe,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF263238),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Divider(height: 1, color: Color(0xFFECEFF1)),
                          const SizedBox(height: 24),
                          // Info Items
                          _buildInfoRow(
                            context,
                            Icons.assignment_outlined,
                            'Mã đề thi',
                            deThi.maDe,
                            colors[0],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            context,
                            Icons.timer_outlined,
                            'Thời gian làm bài',
                            '${deThi.thoiGian} phút',
                            colors[0],
                          ),
                          const SizedBox(height: 16),
                          // Dynamic questions count
                          FutureBuilder<List<CauHoi>>(
                            future: ExamService().getCauHoiByDeThi(deThi.id ?? 1),
                            builder: (context, snapshot) {
                              String qCountText = 'Đang tải số câu hỏi...';
                              if (snapshot.connectionState == ConnectionState.done) {
                                if (snapshot.hasData) {
                                  qCountText = '${snapshot.data!.length} câu hỏi';
                                } else {
                                  qCountText = 'Không tìm thấy câu hỏi';
                                }
                              }
                              return _buildInfoRow(
                                context,
                                Icons.help_outline_rounded,
                                'Số lượng câu hỏi',
                                qCountText,
                                colors[0],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // Instructions Container
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFECEFF1)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 20,
                                  color: colors[0].withOpacity(0.8),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Đề thi này gồm các câu hỏi trắc nghiệm khách quan chuẩn cấu trúc thi THPT Quốc Gia. Bạn có thể xem lại bài làm và lời giải chi tiết sau khi hoàn thành.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF546E7A),
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Start button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: colors,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: colors[0].withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LamBaiScreen(deThi: deThi),
                                  ),
                                );
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'BẮT ĐẦU LÀM BÀI',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
