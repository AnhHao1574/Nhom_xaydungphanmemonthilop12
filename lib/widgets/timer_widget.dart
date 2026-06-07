import 'dart:async';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final int timeInMinutes;
  final VoidCallback onTimeUp;

  const TimerWidget({Key? key, required this.timeInMinutes, required this.onTimeUp}) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late Timer _timer;
  late int _timeLeft;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.timeInMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer.cancel();
        widget.onTimeUp();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return Text(
      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
    );
  }
}