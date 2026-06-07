import 'package:flutter/material.dart';
import '../models/de_thi.dart';
import 'lam_bai_screen.dart';

class DeThiScreen extends StatelessWidget {
  final DeThi deThi;

  const DeThiScreen({super.key, required this.deThi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đề thi')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              deThi.tenDe,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Môn học ID: ${deThi.monHocId} | Mã đề: ${deThi.maDe}'),
            Text('Thời gian làm bài: ${deThi.thoiGian} phút'),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LamBaiScreen(deThi: deThi)),
                );
              },
              child: const Text(
                'BẮT ĐẦU LÀM BÀI',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
