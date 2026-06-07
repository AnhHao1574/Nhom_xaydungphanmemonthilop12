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
    return '$d/$m/${date.year} $h:$min';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Bài Làm'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kq.tenDeThi ?? 'Đề thi #${kq.deThiId}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _infoRow('Điểm số', kq.diem.toStringAsFixed(2)),
                  _infoRow('Số câu đúng', '${kq.soCauDung} câu'),
                  _infoRow('Số câu sai', '${kq.soCauSai} câu'),
                  if (kq.thoiGianLamTuJson > 0)
                    _infoRow('Thời gian làm', _formatDuration(kq.thoiGianLamTuJson)),
                  _infoRow('Ngày làm', _formatNgay(kq.ngayThi)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chi tiết từng câu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._cauHoi.asMap().entries.map((entry) {
            final index = entry.key;
            final ch = entry.value;
            final chon = dapAnChon[ch.id];
            final dung = chon == ch.dapAnDung;
            final boQua = chon == null;

            Color borderColor;
            if (boQua) {
              borderColor = Colors.grey;
            } else if (dung) {
              borderColor = Colors.green;
            } else {
              borderColor = Colors.red;
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: borderColor, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Câu ${index + 1}: ${ch.noiDung}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    if (chon != null)
                      Text(
                        'Bạn chọn: $chon. ${_dapAnText(ch, chon)}',
                        style: TextStyle(
                          color: dung ? Colors.green : Colors.red,
                        ),
                      )
                    else
                      const Text(
                        'Bạn chưa trả lời',
                        style: TextStyle(color: Colors.grey),
                      ),
                    if (!dung || boQua)
                      Text(
                        'Đáp án đúng: ${ch.dapAnDung}. ${_dapAnText(ch, ch.dapAnDung)}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    if (ch.giaiThich != null && ch.giaiThich!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Giải thích: ${ch.giaiThich}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
