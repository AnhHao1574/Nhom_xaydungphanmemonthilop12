import 'package:flutter/material.dart';

import '../models/ket_qua.dart';
import '../services/auth_service.dart';
import '../services/exam_service.dart';
import 'lich_su_chi_tiet_screen.dart';

class LichSuScreen extends StatefulWidget {
  const LichSuScreen({super.key});

  @override
  State<LichSuScreen> createState() => _LichSuScreenState();
}

class _LichSuScreenState extends State<LichSuScreen> {
  final _examService = ExamService();
  List<KetQua> _lichSu = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final userId = AuthService.instance.currentUser?.id;
    final data = await _examService.getLichSuThi(maNguoiDung: userId);
    if (mounted) {
      setState(() {
        _lichSu = data;
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$d/$m/${date.year} $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Làm Bài'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lichSu.isEmpty
              ? const Center(
                  child: Text(
                    'Chưa có lịch sử làm bài nào.\nHãy làm bài thi để xem kết quả tại đây!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _lichSu.length,
                    itemBuilder: (context, index) {
                      final item = _lichSu[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                item.diem >= 5 ? Colors.green : Colors.orange,
                            child: Text(
                              item.diem.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            item.tenDeThi ?? 'Đề thi #${item.deThiId}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item.soCauDung}/${item.soCauDung + item.soCauSai} câu đúng\n'
                            '${_formatDate(item.ngayThi)}',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LichSuChiTietScreen(lichSuId: item.id!),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
