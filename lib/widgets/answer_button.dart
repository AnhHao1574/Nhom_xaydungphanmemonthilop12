import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  final String label; // 'A', 'B', 'C', 'D'
  final String text;  // Nội dung đáp án
  final bool isSelected;
  final VoidCallback onTap;

  const AnswerButton({
    Key? key,
    required this.label,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.white,
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
              child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
}