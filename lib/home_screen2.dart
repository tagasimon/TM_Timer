import 'dart:async';

import 'package:flutter/material.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  HomeScreen2State createState() => HomeScreen2State();
}

class HomeScreen2State extends State<HomeScreen2> {
  int _totalTime = 0; // Duration in minutes to manipulate colors
  int _currentTime = 0; // Current time in seconds
  Timer? _timer;
  Color _backgroundColor = Colors.white;

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }

    setState(() {
      _currentTime = 0;
      _backgroundColor = Colors.white;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime++;

        // Change background color at 50%, 80%, and 100% of the entered duration
        if (_totalTime > 0) {
          double progress = _currentTime / (_totalTime * 60);
          if (progress >= 1.0) {
            _backgroundColor = Colors.red;
          } else if (progress >= 0.8) {
            _backgroundColor = Colors.yellow;
          } else if (progress >= 0.6) {
            _backgroundColor = Colors.green;
          }
        }
      });
    });
  }

  void _stopTimerAndShowSummary() {
    if (_timer != null) {
      _timer!.cancel();
    }

    int minutes = _currentTime ~/ 60;
    int seconds = _currentTime % 60;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Summary"),
          content: Text("Time elapsed: $minutes minutes and $seconds seconds"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('TM Timer App'),
      ),
      body: Container(
        color: _backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Time elapsed: ${_currentTime ~/ 60} minutes and ${_currentTime % 60} seconds',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final int? mins = await showDialog<int>(
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
                              final int? mins = int.tryParse(controller.text);
                              Navigator.of(context).pop(mins);
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                  if (mins == null) return;
                  _totalTime = mins;
                  _startTimer();
                },
                child: const Text('Start Timer'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _stopTimerAndShowSummary,
                child: const Text('End Results'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
