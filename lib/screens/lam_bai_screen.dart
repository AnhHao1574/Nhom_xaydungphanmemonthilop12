import 'package:flutter/material.dart';

import '../models/cau_hoi.dart';
import '../models/de_thi.dart';
import '../models/ket_qua.dart';
import '../services/exam_service.dart';
import '../widgets/question_card.dart';
import '../widgets/timer_widget.dart';
import 'ket_qua_screen.dart';

class LamBaiScreen extends StatefulWidget {
  final DeThi deThi;
  const LamBaiScreen({super.key, required this.deThi});

  @override
  State<LamBaiScreen> createState() => _LamBaiScreenState();
}

class _LamBaiScreenState extends State<LamBaiScreen> {
  final ExamService _examService = ExamService();
  final PageController _pageController = PageController();
  List<CauHoi> _danhSachCauHoi = [];
  final Map<int, String> _dapAnHocSinh = {};
  int _currentIndex = 0;
  bool _isLoading = true;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _loadCauHoi();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadCauHoi() async {
    final qs = await _examService.getCauHoiByDeThi(widget.deThi.id ?? 1);
    setState(() {
      _danhSachCauHoi = qs;
      _isLoading = false;
    });
  }

  Future<void> _nopBai() async {
    try {
      // Hiển thị loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Đang lưu kết quả...'),
              ],
            ),
          ),
        );
      }

      final thoiGianLamGiay = DateTime.now().difference(_startTime).inSeconds;
      final kq = _examService.chamDiem(
        deThiId: widget.deThi.id ?? 1,
        danhSachCauHoi: _danhSachCauHoi,
        dapAnHocSinh: _dapAnHocSinh,
        thoiGianLamGiay: thoiGianLamGiay,
        tenDeThi: widget.deThi.tenDe,
      );

      final id = await _examService.luuKetQua(kq);
      
      if (!mounted) return;
      
      final savedKq = KetQua(
        id: id,
        maNguoiDung: kq.maNguoiDung,
        deThiId: kq.deThiId,
        tenDeThi: kq.tenDeThi,
        diem: kq.diem,
        soCauDung: kq.soCauDung,
        soCauSai: kq.soCauSai,
        thoiGianLam: kq.thoiGianLam,
        ngayThi: kq.ngayThi,
        danhSachDapAnChon: kq.danhSachDapAnChon,
      );

      // Đóng loading dialog và điều hướng đến màn hình kết quả
      Navigator.pop(context); // Đóng loading dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => KetQuaScreen(ketQua: savedKq)),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Đóng loading dialog nếu mở
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu kết quả: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showNopBaiDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận nộp bài'),
        content: const Text('Bạn có chắc chắn muốn nộp bài ngay không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _nopBai(); // Gọi hàm async mà không cần await tại đây
            },
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_danhSachCauHoi.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Làm bài')),
        body: const Center(child: Text('Đề thi này chưa có câu hỏi.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Câu ${_currentIndex + 1}/${_danhSachCauHoi.length}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TimerWidget(
                timeInMinutes: widget.deThi.thoiGian,
                onTimeUp: _nopBai,
              ),
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _danhSachCauHoi.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          final ch = _danhSachCauHoi[index];
          return QuestionCard(
            index: index + 1,
            cauHoi: ch,
            selectedAnswer: _dapAnHocSinh[ch.id],
            onAnswerSelected: (ans) {
              setState(() => _dapAnHocSinh[ch.id!] = ans);
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Câu trước'),
                onPressed: _currentIndex > 0
                    ? () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _showNopBaiDialog,
                child: const Text('NỘP BÀI', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: _currentIndex < _danhSachCauHoi.length - 1
                    ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
                child: const Row(
                  children: [
                    Text('Câu sau'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
