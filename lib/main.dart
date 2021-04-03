import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _todoList = [];
  var newTaskController = TextEditingController();
  var _lastRemovedTask;
  var _lastRemovedTaskIndex;

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _todoList = json.decode(data);
      });
    });
  }

  void _addTodo() {
    var taskTodo = newTaskController.text;

    setState(() {
      _todoList.add({'title': taskTodo, 'done': false});
      newTaskController.text = "";
    });

    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Todo list"),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        ),
        body: Column(children: [
          Container(
              padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
              child: Row(children: [
                Expanded(
                  child: TextField(
                      controller: newTaskController,
                      decoration: InputDecoration(
                          labelText: "New Task",
                          labelStyle: TextStyle(color: Colors.blueAccent))),
                ),
                ElevatedButton(
                  child: Text('Add'),
                  onPressed: _addTodo,
                )
              ])),
          Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemCount: _todoList.length,
                  itemBuilder: buildTodoItem))
        ]));
  }

  Widget buildTodoItem(context, index) {
    return Dismissible(
      key: Key(Uuid().v4()),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      child: CheckboxListTile(
        title: Text(_todoList[index]["title"]),
        value: _todoList[index]["done"],
        secondary: CircleAvatar(
          child: Icon(_todoList[index]["done"]
              ? Icons.check
              : Icons.radio_button_unchecked),
        ),
        onChanged: (check) {
          setState(() {
            _todoList[index]["done"] = check;
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemovedTaskIndex = index;
          _lastRemovedTask = _todoList[index];
          _todoList.removeAt(index);
        });

        _saveData();

        final snack = SnackBar(
            content: Text("Task '${_lastRemovedTask["title"]}' was removed!"),
            action: SnackBarAction(
              label: "undo",
              onPressed: () {
                setState(() {
                  _todoList.insert(index, _lastRemovedTask);
                  _saveData();
                });
              },
            ),
            duration: Duration(seconds: 2));

        ScaffoldMessenger.of(context).showSnackBar(snack);
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/todo_data.json");
  }

  Future<File> _saveData() async {
    var data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    var file = await _getFile();

    try {
      return file.readAsString();
    } catch (e) {}
  }
}
