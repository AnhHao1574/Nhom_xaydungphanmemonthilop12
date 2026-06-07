import 'package:flutter/material.dart';
import '../models/cau_hoi.dart';
import 'answer_button.dart';

class QuestionCard extends StatelessWidget {
  final int index;
  final CauHoi cauHoi;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;

  const QuestionCard({
    super.key,
    required this.index,
    required this.cauHoi,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Tự động kiểm tra để loại bỏ chữ "Câu X:" bị lặp lại
    String hienThiNoiDung = cauHoi.noiDung;
    if (!hienThiNoiDung.trim().startsWith('Câu')) {
      hienThiNoiDung = 'Câu $index: $hienThiNoiDung';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hienThiNoiDung,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          AnswerButton(label: 'A', text: cauHoi.dapAnA, isSelected: selectedAnswer == 'A', onTap: () => onAnswerSelected('A')),
          AnswerButton(label: 'B', text: cauHoi.dapAnB, isSelected: selectedAnswer == 'B', onTap: () => onAnswerSelected('B')),
          AnswerButton(label: 'C', text: cauHoi.dapAnC, isSelected: selectedAnswer == 'C', onTap: () => onAnswerSelected('C')),
          AnswerButton(label: 'D', text: cauHoi.dapAnD, isSelected: selectedAnswer == 'D', onTap: () => onAnswerSelected('D')),
        ],
      ),
    );
  }
}