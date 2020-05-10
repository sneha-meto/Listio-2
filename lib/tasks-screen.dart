import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add-task-screen.dart';
import 'edit-task-screen.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => AddTaskScreen()));
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 130),
                child: Text(
                  'Listio',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 50,
                      fontFamily: 'ShadowsIntoLightTwo'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: StreamBuilder(
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData)
                      return Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    return TaskList(
                      document: snapshot.data.documents,
                    );
                  },
                  stream: Firestore.instance.collection('tasks').snapshots(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  final List<DocumentSnapshot> document;
  TaskList({this.document});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int i) {
        String title = document[i].data['title'].toString();
        DateTime _date = document[i].data['duedate'].toDate();
        String duedate = '${_date.day}-${_date.month}-${_date.year}';
        String note = document[i].data['note'].toString();
        return Dismissible(
          key: Key(document[i].documentID),
          onDismissed: (direction) {
            Firestore.instance.runTransaction((transaction) async {
              DocumentSnapshot snapshot =
                  await transaction.get(document[i].reference);
              await transaction.delete((snapshot.reference));
            });
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Task removed.'),
            ));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: TextStyle(
                                fontSize: 20,
                                letterSpacing: 1,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            duedate,
                            style: TextStyle(fontSize: 18, letterSpacing: 1),
                          ),
                          Text(
                            note,
                            style: TextStyle(fontSize: 18, letterSpacing: 1),
                          ),
                          Card()
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => EditTaskScreen(
                                  title: title,
                                  note: note,
                                  duedate: document[i].data['duedate'].toDate(),
                                  index: document[i].reference,
                                )));
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
      itemCount: document.length,
    );
  }
}
