import 'package:flutter/material.dart';

import '../models/cau_hoi.dart';
import '../models/ket_qua.dart';
import '../services/exam_service.dart';

class LichSuChiTietScreen extends StatefulWidget {
  final int lichSuId;

  const LichSuChiTietScreen({super.key, required this.lichSuId});

  @override
  State<LichSuChiTietScreen> createState() => _LichSuChiTietScreenState();
}

class _LichSuChiTietScreenState extends State<LichSuChiTietScreen> {
  final _examService = ExamService();
  KetQua? _ketQua;
  List<CauHoi> _cauHoi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final ketQua = await _examService.getChiTietLichSu(widget.lichSuId);
    if (ketQua == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final cauHoi = await _examService.getCauHoiByDeThi(ketQua.deThiId);
    if (mounted) {
      setState(() {
        _ketQua = ketQua;
        _cauHoi = cauHoi;
        _isLoading = false;
      });
    }
  }

  String _formatNgay(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$d/$m/${date.year}  $h:$min';
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _dapAnText(CauHoi ch, String letter) {
    switch (letter) {
      case 'A':
        return ch.dapAnA;
      case 'B':
        return ch.dapAnB;
      case 'C':
        return ch.dapAnC;
      case 'D':
        return ch.dapAnD;
      default:
        return '';
    }
  }

  Color _scoreColor(double diem) {
    if (diem >= 8.0) return const Color(0xFF2E7D32);
    if (diem >= 5.0) return const Color(0xFFF57F17);
    return const Color(0xFFC62828);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_ketQua == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết bài làm')),
        body: const Center(child: Text('Không tìm thấy dữ liệu.')),
      );
    }

    final kq = _ketQua!;
    final dapAnChon = kq.dapAnDaChon;
    final sc = _scoreColor(kq.diem);
    final tongCau = kq.soCauDung + kq.soCauSai;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Chi Tiết Bài Làm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Summary Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kq.tenDeThi ?? 'Đề thi #${kq.deThiId}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatNgay(kq.ngayThi),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Score & Stats Cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                // Score
                Expanded(
                  child: _statCard(
                    label: 'Điểm số',
                    value: kq.diem.toStringAsFixed(1),
                    valueColor: sc,
                    icon: Icons.star_rounded,
                    iconColor: sc,
                  ),
                ),
                const SizedBox(width: 10),
                // Correct
                Expanded(
                  child: _statCard(
                    label: 'Đúng',
                    value: '${kq.soCauDung}/$tongCau',
                    valueColor: const Color(0xFF2E7D32),
                    icon: Icons.check_circle_outline,
                    iconColor: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 10),
                // Time
                Expanded(
                  child: _statCard(
                    label: 'Thời gian',
                    value: kq.thoiGianLamTuJson > 0
                        ? _formatDuration(kq.thoiGianLamTuJson)
                        : '--:--',
                    valueColor: const Color(0xFF37474F),
                    icon: Icons.timer_outlined,
                    iconColor: const Color(0xFF546E7A),
                  ),
                ),
              ],
            ),
          ),

          // Questions header
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Chi tiết từng câu',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Question list
          ...List.generate(_cauHoi.length, (index) {
            final ch = _cauHoi[index];
            final chon = dapAnChon[ch.id];
            final dung = chon == ch.dapAnDung;
            final boQua = chon == null;

            Color borderColor;
            Color bgColor;
            IconData statusIcon;
            if (boQua) {
              borderColor = Colors.grey.shade300;
              bgColor = Colors.grey.shade50;
              statusIcon = Icons.remove_circle_outline;
            } else if (dung) {
              borderColor = const Color(0xFF66BB6A);
              bgColor = const Color(0xFFE8F5E9);
              statusIcon = Icons.check_circle;
            } else {
              borderColor = const Color(0xFFEF5350);
              bgColor = const Color(0xFFFFEBEE);
              statusIcon = Icons.cancel;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: borderColor, width: 1.2),
                ),
                color: bgColor,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(statusIcon, color: borderColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Câu ${index + 1}: ${ch.noiDung}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (chon != null)
                        _answerRow(
                          'Bạn chọn:',
                          '$chon. ${_dapAnText(ch, chon)}',
                          dung ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                        )
                      else
                        _answerRow(
                          'Bạn chưa trả lời',
                          '',
                          Colors.grey,
                        ),
                      if (!dung || boQua)
                        _answerRow(
                          'Đáp án đúng:',
                          '${ch.dapAnDung}. ${_dapAnText(ch, ch.dapAnDung)}',
                          const Color(0xFF2E7D32),
                        ),
                      if (ch.giaiThich != null &&
                          ch.giaiThich!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          '💡 ${ch.giaiThich}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _answerRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 2),
      child: Text(
        value.isEmpty ? label : '$label $value',
        style: TextStyle(fontSize: 13, color: color),
      ),
    );
  }
}
