import 'package:flutter/material.dart';
import 'package:todolist/todo_item.dart';

import 'database/database_helper.dart';
import 'date_formattter.dart';

var controller=TextEditingController();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //h3ml instance mn el database
  var db = new DatabaseHelper();
  final List<TodoItem> _itemsList = <TodoItem>[];

  @override
  void initState() {
    super.initState();
    _readTodoList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Todo'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
         setState(() {
           buidAlert();
         });
        },
      ),
      body:Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
                itemCount: _itemsList.length,
                itemBuilder: (_, int index) {
                  return Card(
                    color: Colors.white,
                    child: ListTile(
                      title: _itemsList[index],
                      onLongPress: () => _updateItem(_itemsList[index], index),
                      trailing:
                      new Listener(
                        key: Key(_itemsList[index].itemName),
                        child: Icon(
                          Icons.remove_circle,
                          color: Colors.redAccent,
                        ),
                        onPointerDown: (pointerEvent){
                          _handleDelete(_itemsList[index].id, index);
                          },
                      ),
                    ),
                  );
                }),
          ),
          Divider(
            height: 1.0,
          )
        ],
      ),
    );

  }
  void buidAlert(){
    final AlertDialog alert = AlertDialog(
      content: Row(children: [
        Expanded(child: TextField(
          controller:controller,
          autofocus: true,
          decoration: InputDecoration(
              labelText: ('Description'),
              icon: Icon(Icons.notifications)),
        ))
      ],),
        actions: [
          FlatButton(onPressed: (){
            _handeledMethod(controller.text);
            controller.clear();
            Navigator.pop(context);

            }, child: Text('save')),
          FlatButton(onPressed: (){Navigator.pop(context);}, child: Text('close')),

        ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }
  // lma el user yd8t save mn el alert tt5zn el bianat
  // el txt ely el user hyda5alo
  Future<void> _handeledMethod(String text) async {
    // هاخد الوقت الحالي واحوله
    // el text ely ha5do mn el user bta3 el controller
    TodoItem todoItem = new TodoItem(text,DateTime.now().toIso8601String());
    int SavedItemId = await db.saveItem(todoItem);
    print(SavedItemId);
    //3iza ageb el item
    TodoItem item =await db.getItem(SavedItemId);
    print(item.itemName);
    setState(() {
      _itemsList.insert(0, item);
    });
  }


  _readTodoList() async {
    List items = await db.getAllItems();
    items.forEach((item) {
      setState(() {
        _itemsList.add(TodoItem.map(item));
      });
    });
  }
  _handleDelete(int id, int index) async {
    await db.deleteItem(id);
    setState(() {
      _itemsList.removeAt(index);
    });
  }
  _updateItem(TodoItem item, int index) {
    var alert = new AlertDialog(
      title: Text("Update Item"),
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: TextField(
                controller: controller,
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: "Item",
                    hintText: "e.g buy breads",
                    icon: Icon(Icons.add_alert)),
              ))
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () async {
              TodoItem updatedItem = TodoItem.fromMap({
                "itemName": controller.text,
                "dateCreated": dateFormatter(),
                "id": item.id
              });
              _handleUpdate(index, updatedItem);
              await db.updateItem(updatedItem);
              setState(() {
                _readTodoList();
              });
              controller.clear();
              Navigator.pop(context);
            },
            child: Text("Save")),
        new FlatButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel"))
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  void _handleUpdate(int index, TodoItem updatedItem) {
    setState(() {
      _itemsList.removeWhere((element) {
        _itemsList[index].itemName == updatedItem.itemName;
      });
    });
  }
}
