import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:todolist/screens/add_page.dart';
import 'package:http/http.dart' as http;

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  bool isloading = true;
  List dataList = [];
  @override
  void initState() {
    super.initState();
    featchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("To Do List")),
      body: Visibility(
        visible: isloading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: featchTodo,
          child: ListView.builder(
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              final item = dataList[index]  as Map;
            return ListTile(
              leading: CircleAvatar(child: Text('${index+1}'),),
              title: Text(dataList[index]['title']),
              subtitle: Text(dataList[index]['description']),
              trailing: PopupMenuButton(
                onSelected: (value) async {
                  if(value == "edit"){
                    navigateToEditPage(item);

                  }else if(value == "delete"){
                    final id = dataList[index]["_id"];
                    deleteById(id);
                  }
                },
                itemBuilder: (context) {
                  return [
                    CheckedPopupMenuItem(child: Text("Edit"),value: "edit",),
                    CheckedPopupMenuItem(child: Text("Delete"), value: "delete",)
                  ];
                },
              ),
            );
          },),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            navigateToAddPage();
          },
          label: Text("Add To Do"),backgroundColor: Colors.white),
    );
  }

  Future<void> navigateToEditPage(Map item) async{
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPage(todo: item),
        ));
    setState(() {
      isloading = true;
    });
    featchTodo();
  }

  Future<void> navigateToAddPage() async{
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPage(),
        ));
    setState(() {
      isloading = true;
    });
    featchTodo();
  }

  Future<void> featchTodo() async{

    var response = await http.get(Uri.parse("https://api.nstack.in/v1/todos?page=1&limit=10"));
    var data = jsonDecode(response.body.toString()) as Map;
    if(response.statusCode == 200){
      final result = data['items'] as List;
      setState(() {
        dataList = result;
        //print(dataList);
      });
    }
    setState(() {
      isloading = false;
    });
  }

  Future<void> deleteById(id) async{
    final response = await http.delete(Uri.parse("https://api.nstack.in/v1/todos/$id"));
    if(response.statusCode == 200){
      final filter = dataList.where((element) => element["_id"] != id).toList();
      setState(() {
        dataList = filter;
      });
    }else{
      print("Delete Failed");
    }
  }
}
