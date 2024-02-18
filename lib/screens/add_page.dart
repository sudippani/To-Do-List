import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPage extends StatefulWidget {
  final Map? todo;
  const AddPage({super.key, this.todo});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      isEdit = true;
      final title = widget.todo?['title'];
      final description = widget.todo?['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(isEdit ? "Edit To Do" : "Add To Do"), centerTitle: true),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                    hintText: "Title",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ))),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                controller: descriptionController,
                maxLines: 8,
                minLines: 5,
                decoration: InputDecoration(
                    hintText: "Description",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ))),
          ),
          SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Colors.white,
              ),
              child: TextButton(
                onPressed: () {
                  isEdit ? updateData() : submitData();
                },
                child: Text(
                  isEdit ? "Edit" : "Submit",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final id = widget.todo?['_id'];

    final response =
        await http.put(Uri.parse("https://api.nstack.in/v1/todos/$id"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "title": titleController.text,
              "description": descriptionController.text,
              "is_completed": false
            }));
    if (response.statusCode == 200) {
      titleController.text = "";
      descriptionController.text = "";
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Updation Success"),
        backgroundColor: Colors.green,
      ));
    } else {
      print("Error");
      print(response.statusCode);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Updation Failed"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> submitData() async {
    var response = await http.post(Uri.parse("https://api.nstack.in/v1/todos"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "title": titleController.text,
          "description": descriptionController.text,
          "is_completed": false
        }));
    if (response.statusCode == 201) {
      titleController.text = "";
      descriptionController.text = "";
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Creation Success"),
        backgroundColor: Colors.green,
      ));
    } else {
      print("Error");
      print(response.statusCode);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Creation Failed"),
        backgroundColor: Colors.red,
      ));
    }
  }
}
