import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  DateTime _dueDate = DateTime.now();
  String _dateText = '';
  String note = '';
  String newTask = '';

  Future<Null> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _dueDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2050));
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dateText = '${picked.day}-${picked.month}-${picked.year}';
      });
    }
  }

  void _save() {
    Firestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference = Firestore.instance.collection('tasks');
      await reference.add({
        "title": newTask,
        "duedate": _dueDate,
        "note": note,
      });
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _dateText = '${_dueDate.day}-${_dueDate.month}-${_dueDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                color: Colors.black,
                child: Text(
                  'Add Task',
                  style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'ShadowsIntoLightTwo',
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )),
            Padding(
                padding: EdgeInsets.all(20),
                child: TextField(
                    onChanged: (String value) {
                      newTask = value;
                    },
                    style: TextStyle(fontSize: 20, color: Colors.black),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'New Task',
                        icon: Icon(
                          Icons.list,
                          color: Colors.black,
                        )))),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  Icon(Icons.date_range),
                  SizedBox(
                    width: 18,
                  ),
                  Expanded(
                    child: Text('Due :',
                        style: TextStyle(fontSize: 20, color: Colors.black)),
                  ),
                  FlatButton(
                    onPressed: () => _selectDueDate(context),
                    child: Text('$_dateText',
                        style: TextStyle(fontSize: 20, color: Colors.black)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  Icon(Icons.note),
                  SizedBox(
                    width: 18,
                  ),
                  Text('Note :',
                      style: TextStyle(fontSize: 20, color: Colors.black)),
                  Expanded(
                    child: TextField(
                      onChanged: (String value) {
                        note = value;
                      },
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '  Add a note.',
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.check),
                    iconSize: 35,
                    onPressed: () {
                      _save();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    iconSize: 35,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
