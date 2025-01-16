import 'package:flutter/material.dart';
import 'package:sqflite_tutorial/services/local_db.dart';

class TasksScreen extends StatefulWidget {
  TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();

  bool hide=false;
  String test="";
}

class _TasksScreenState extends State<TasksScreen> {
  final LocalDb localDb = LocalDb();
  final nameCntrl = TextEditingController();
  final descriptionCntrl = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameCntrl.dispose();
    descriptionCntrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: localDb.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Center(child: Text("No tasks found"));
            }
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                final Map<String, dynamic> task = snapshot.data![index];
                return Dismissible(
                  onDismissed: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      await localDb.deleteTask(task['id']);
                      setState(() {
                        
                      });
                    } else if (direction == DismissDirection.startToEnd) {
                      _showModalSheet(
                        context: context,
                        isEditing: true,
                        task: task,
                      );
                    }
                    setState(() {});
                    // if (direction == DismissDirection.horizontal) {
                    //   await localDb.deleteTask(task['id']);
                    //   setState(() {});
                    // }
                  },
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: const [
                        Icon(Icons.edit, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Edit task',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Text('Delete', style: TextStyle(color: Colors.white)),
                        SizedBox(width: 10),
                        Icon(Icons.delete, color: Colors.white),
                      ],
                    ),
                  ),
                  direction: DismissDirection.horizontal,
                  key: Key((snapshot.data![index]["id"]).toString()),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, right: 4, left: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        // onLongPress: () async {
                        //   await localDb.deleteTask(task["id"]);
                        //   setState(() {});
                        // },
                        title: Row(
                          children: [
                            Text(
                              task["isHideItem"]==0 ?  task["name"]: "",
                              style: TextStyle(
                                decoration: task["status"] == 1
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                                onPressed: () async{
                                  task["isHideItem"]==0;

                                  await localDb.updateHide(
                                    id: task["id"],
                                    newValue: task["isHideItem"]==0? 1 : 0,
                                    );
                                  setState(() {

                                  });
                                },
                                icon: Icon(task["isHideItem"]==0 ? Icons.visibility_off : Icons.visibility)),
                            IconButton(
                                onPressed: () {

                                  _showModalSheet(context: context, isEditing: true, task: task);
                                  setState(() {

                                  });

                                }, icon: Icon(Icons.edit)),
                            IconButton(
                                onPressed: () async{
                                  await localDb.deleteTask(task["id"]);
                                  setState(() {

                                  });
                                }, icon: Icon(Icons.delete)),
                          ],
                        ),
                        // subtitle: Text(
                        //   style: TextStyle(
                        //     decoration: task["status"] == 1
                        //         ? TextDecoration.lineThrough
                        //         : TextDecoration.none,
                        //   ),
                        //   task["description"],
                        // ),
                        leading: Checkbox(
                          value: task["status"] == 1,
                          onChanged: (value) async {
                            await localDb.updateStatus(
                              id: task["id"],
                              newValue: value == true ? 1 : 0,
                            );
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: Text("Error happened while loading tasks"),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showModalSheet(context: context, isEditing: false);
          setState(() {

          });
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }

  Future<dynamic> _showModalSheet({
    required BuildContext context,
    required bool isEditing,
    Map<String, dynamic>? task,
  }) {
    if (isEditing) {
      nameCntrl.text = task!["name"].toString();
      descriptionCntrl.text = task["description"];
    }
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(child: Text("Add new task")),
            TextField(
              controller: nameCntrl,
            ),
            TextField(
              controller: descriptionCntrl,
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                if (nameCntrl.text.trim().isEmpty ||
                    descriptionCntrl.text.trim().isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Okay"),
                          ),
                        ],
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Please add task name and description",
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  if (isEditing) {
                    await localDb.updateTask(
                        name: nameCntrl.text.trim(),
                        description: descriptionCntrl.text.trim(),
                        id: task!["id"]);
                  } else {
                    await localDb.addTask(
                      name: nameCntrl.text.trim(),
                      description: descriptionCntrl.text.trim(),
                    );
                  }
                  nameCntrl.clear();
                  descriptionCntrl.clear();

                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text(isEditing ? "Update" : "Create"),
            ),
          ],
        );
      },
    );
  }
}
