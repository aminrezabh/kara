import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kara',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ToDoClockApp(),
    );
  }
}

class ToDoClockApp extends StatefulWidget {
  @override
  _ToDoClockAppState createState() => _ToDoClockAppState();
}

class _ToDoClockAppState extends State<ToDoClockApp> {
  TextEditingController _taskController = TextEditingController();
  List<Task> _tasks = [];
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    updateTime();
    Timer.periodic(Duration(seconds: 1), (Timer t) => updateTime());
  }

  void updateTime() {
    setState(() {
      _currentTime = DateTime.now().toString().substring(11, 19);
    });
  }

  void addTask(
    String newTask,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    DateTime? date,
  ) {
    setState(() {
      if (newTask.isNotEmpty && startTime != null && endTime != null) {
        _tasks.add(
          Task(
            description: newTask,
            isCompleted: false,
            date: date, // Include date when creating the task
            specialStartTime: startTime,
            specialEndTime: endTime,
          ),
        );
      }
    });
  }

  void toggleTask(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    TimeOfDay? selectedStartTime = const TimeOfDay(hour: 00, minute: 00);
    TimeOfDay? selectedEndTime = const TimeOfDay(hour: 00, minute: 00);
    DateTime? selectedDate; // Newly added

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  hintText: 'Enter task...',
                ),
              ),
              const SizedBox(height: 10.0),
              ListTile(
                title: const Text('Set Date'), // New ListTile for Date
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 5),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Set Start Time'),
                trailing: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () async {
                    TimeOfDay? pickedStartTime = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 00, minute: 00),
                    );
                    if (pickedStartTime != null) {
                      setState(() {
                        selectedStartTime = pickedStartTime;
                      });
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Set End Time'),
                trailing: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () async {
                    TimeOfDay? pickedEndTime = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 00, minute: 00),
                    );
                    if (pickedEndTime != null) {
                      setState(() {
                        selectedEndTime = pickedEndTime;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                addTask(
                  _taskController.text,
                  selectedStartTime,
                  selectedEndTime,
                  selectedDate, // Pass selectedDate to addTask
                );
                _taskController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ... (Previous code remains unchanged)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kara'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: Checkbox(
                      value: _tasks[index].isCompleted,
                      onChanged: (_) => toggleTask(index),
                    ),
                    title: Text(
                      _tasks[index].description,
                      style: TextStyle(
                        decoration: _tasks[index].isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: _tasks[index].specialStartTime !=
                                const TimeOfDay(hour: 00, minute: 00) &&
                            _tasks[index].specialEndTime !=
                                const TimeOfDay(hour: 00, minute: 00)
                        ? Text(
                            'Time: ${_tasks[index].specialStartTime!.format(context)} - ${_tasks[index].specialEndTime!.format(context)}')
                        : null,
                    // Display date if available for the task
                    trailing: _tasks[index].date != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                '${_tasks[index].date!.day}/${_tasks[index].date!.month}/${_tasks[index].date!.year}',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _tasks.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          )
                        : IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _tasks.removeAt(index);
                              });
                            },
                          ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              _currentTime,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24.0),
            ),
            const SizedBox(height: 0.0),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'v1.0.0',
                style: TextStyle(fontSize: 10.0, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Task {
  String description;
  bool isCompleted;
  DateTime? date; // New field for the date
  TimeOfDay? specialStartTime;
  TimeOfDay? specialEndTime;

  Task({
    required this.description,
    required this.isCompleted,
    this.date, // Include date in the constructor
    this.specialStartTime,
    this.specialEndTime,
  });
}
