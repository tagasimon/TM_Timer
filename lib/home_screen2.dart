import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  HomeScreen2State createState() => HomeScreen2State();
}

class HomeScreen2State extends State<HomeScreen2> {
  final key = GlobalKey<FormState>();
  final minsController = TextEditingController();
  final speakerNameController = TextEditingController();
  String? speakerName;
  int speaker = 1;
  final List<String> _list = [];
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

  Future<void> _startTimerAction() async {
    final int? mins = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter duration in minutes and speaker name"),
          content: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: speakerNameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    hintText: "Enter Speaker Name",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter speaker name";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: minsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter duration in minutes",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter duration in minutes";
                    }
                    if (int.tryParse(value) == null) {
                      return "Please enter a valid number";
                    }
                    return null;
                  },
                ),
              ],
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
                if (!key.currentState!.validate()) {
                  return;
                }
                final int? mins = int.tryParse(minsController.text);
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
  }

  void _stopTimerAndShowSummary() {
    if (_timer != null) {
      _timer!.cancel();
    }

    int minutes = _currentTime ~/ 60;
    int seconds = _currentTime % 60;
    Fluttertoast.showToast(
      msg:
          "Speaker $speaker: $minutes minutes and $seconds seconds of $_totalTime minutes",
      toastLength: Toast.LENGTH_LONG,
    );
    setState(() {});
    _list.add(
        "${speakerNameController.text}: $minutes minutes and $seconds seconds of $_totalTime minutes");
  }

  void resetTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _currentTime = 0;
      _backgroundColor = Colors.white;
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
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('TM Time Keeper'),
        centerTitle: true,
        actions: [
          OutlinedButton(
            onPressed: _startTimerAction,
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 5),
          OutlinedButton.icon(
            onPressed: _stopTimerAndShowSummary,
            icon: const Icon(Icons.stop),
            label: const Text("Results"),
          ),
          const SizedBox(width: 5),
          OutlinedButton(
            onPressed: resetTimer,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Time elapsed: ${_currentTime ~/ 60} minutes and ${_currentTime % 60} seconds',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 2,
            child: _list.isEmpty
                ? const Center(child: Text("No results yet"))
                : ListView.builder(
                    itemCount: _list.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(_list[index]),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _list.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
