import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
       ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
final _todoCOntroller = TextEditingController();
  List _todoList = [];

  late Map<String, dynamic> _lastRemoved ;
  int _lastRemovedPos =0;

void addTodo(){
setState(() {
  Map<String, dynamic> newTodo = {};
  newTodo["title"] = _todoCOntroller.text;
  _todoCOntroller.text = "";
  newTodo ["ok"] = false;
  _todoList.add(newTodo);
  _saveData();
});
}

Future<Null> _refresh() async{
  await Future.delayed(Duration(seconds: 1));
  setState(() {
    _todoList.sort((a,b){
      if(a["ok"] && !b["ok"]) {
        return 1;
      } else if(!a["ok"] && b["ok"]) {
        return -1;
      } else {
        return 0;
      }
    });
    _saveData();
  });

  return null;
}
  @override
  void initState() {
    super.initState();
    setState(() {
      _readData().then((data) => {
      _todoList = json.decode(data!)
      });
  });}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista de tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children:<Widget> [
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: [
               Expanded(child:  TextField(
                 controller: _todoCOntroller,
                 decoration: InputDecoration(
                   labelText: "Nova Tarefa",
                   labelStyle: TextStyle(color: Colors.blueAccent)
               ),
               ),),
                ElevatedButton(  onPressed: addTodo,
                child: Text("ADD"))
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator( onRefresh: _refresh,
              child: ListView.builder(
            padding: EdgeInsets.only(top: 10),
            itemCount: _todoList.length,
             itemBuilder: buildItem)
            ),
          )
        ],
      ),
    );
  }
  Widget buildItem(context,index){
      return Dismissible(key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
          background: Container(
            color: Colors.red,
            child: Align(
              alignment: Alignment(-0.9, 0.0),
              child: Icon(Icons.delete,color: Colors.white,),
            ),
          ),
        direction: DismissDirection.startToEnd,
        child:CheckboxListTile(
            title: Text(
                _todoList[index]["title"]),
            value: _todoList[index]["ok"],
            secondary: CircleAvatar(
                child: Icon(_todoList[index]["ok"]?
                Icons.check: Icons.error),),
            onChanged: (c) {
              setState(() {
                _todoList[index]["ok"] = c;
                _saveData();
              });
            },
        ),
        
        onDismissed: (direction){
        setState(() {
          _lastRemoved = Map.from(_todoList[index]);
          _lastRemovedPos = index;
          _todoList.removeAt(index);
          _saveData();
        });
        final snack = SnackBar(content:
        Text("Tarefa \"${_lastRemoved['title'] }\" removida!"),
          action: SnackBarAction(label: "Desfazer",
          onPressed: (){
            setState(() {
              _todoList.insert(_lastRemovedPos, _lastRemoved);
              _saveData();
            });
          },
          ),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snack);
        },
      );
  }


  Future<File> _getFile() async{
    final directory = await getApplicationDocumentsDirectory(); //Identifica o caminho do diretorio seja android ou ios
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async{
    String data = json.encode(_todoList); // pega a lista, armazena e transforma em json :)
    final file  = await _getFile();
    return file.writeAsString(data);
  }

  Future<String?> _readData() async{
    try{
      final file = await _getFile();

      return file.readAsString();
    }catch(e){
      return null;
  }

}
  }

