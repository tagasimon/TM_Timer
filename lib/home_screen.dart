import 'dart:async';

import 'package:flutter/material.dart';

class HomeScreen1 extends StatefulWidget {
  const HomeScreen1({super.key});

  @override
  HomeScreen1State createState() => HomeScreen1State();
}

class HomeScreen1State extends State<HomeScreen1> {
  int _totalTime = 0;
  int _currentTime = 0;
  Timer? _timer;
  Color _backgroundColor = Colors.white;

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }

    setState(() {
      _currentTime = _totalTime;
      _backgroundColor = Colors.white;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTime > 0) {
        setState(() {
          _currentTime--;

          // Change background color at 50%, 80%, and 100% of the time spent
          double progress = (_totalTime - _currentTime) / _totalTime;
          if (progress >= 1.0) {
            _backgroundColor = Colors.red;
            timer.cancel();
          } else if (progress >= 0.9) {
            _backgroundColor = Colors.yellow;
          } else if (progress >= 0.5) {
            _backgroundColor = Colors.green;
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              final double? mins = await showDialog<double>(
                context: context,
                builder: (context) {
                  final controller = TextEditingController();
                  return AlertDialog(
                    title: const Text("Enter duration in minutes"),
                    content: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Enter duration in minutes",
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          final double? mins = double.tryParse(controller.text);
                          Navigator.of(context).pop(mins);
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  );
                },
              );
              if (mins != null) {
                _totalTime = (mins * 60).toInt();
              }
              _startTimer();
            },
            icon: const Icon(Icons.play_arrow),
          ),
          IconButton(
            onPressed: () {
              if (_timer != null) {
                _timer!.cancel();
              }
            },
            icon: const Icon(Icons.stop),
          ),
          // add reset button here
          IconButton(
              onPressed: () {
                if (_timer != null) {
                  _timer!.cancel();
                }
                setState(() {
                  _currentTime = 0;
                });
              },
              icon: const Icon(Icons.replay)),
        ],
      ),
      backgroundColor: _backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Time remaining: $_currentTime Seconds',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
