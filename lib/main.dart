import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? task;
  final db = FirebaseFirestore.instance;
  void dialog(bool isUpdate, DocumentSnapshot? ds) {
    GlobalKey<FormState> formKey = GlobalKey();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: !isUpdate ? Text("Add ToDo") : Text("Update Todo"),
            content: Form(
              key: formKey,
              autovalidate: true,
              child: TextFormField(
                  autofocus: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "task",
                  ),
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Can't be Empty";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    task = value;
                  }),
            ),
            actions: <Widget>[
              RaisedButton(
                onPressed: () {
                  if (isUpdate) {
                    db
                        .collection('task')
                        .doc(ds?.id)
                        .update({'task': task, 'time': DateTime.now()});
                  } else {
                    db
                        .collection('task')
                        .add({'task': task, 'time': DateTime.now()});
                  }
                  Navigator.pop(context);
                },
                child: !isUpdate ? Text("Add") : Text("Update"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => dialog(false, null),
            child: Icon(Icons.add),
          ),
          appBar: AppBar(
            title: Text("CRUD"),
            centerTitle: true,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: db.collection('task').orderBy('time').snapshots(),
            builder: (context, snapshots) {
              if (snapshots.hasData) {
                return ListView.builder(
                  itemCount: snapshots.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshots.data!.docs[index];
                    return Container(
                      child: ListTile(
                        title: Text(ds['task']),
                        onLongPress: () {
                          db.collection('task').doc(ds.id).delete();
                        },
                        onTap: () {
                          dialog(true, ds);
                        },
                      ),
                    );
                  },
                );
              } else if (snapshots.hasError) {
                return CircularProgressIndicator();
              } else {
                return CircularProgressIndicator();
              }
            },
          )),
    );
  }
}
