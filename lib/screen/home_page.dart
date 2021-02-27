import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:task_list/model/file_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _tasks = [];
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _lastTaskRemoved = Map();
  TextEditingController _controllerField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Tarefas"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: createListTasks,
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Adicionar Tarefa'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () => _showDialogWidget(),
      ),
    );
  }

  void _saveTask() {
    Map<String, dynamic> task = Map();

    task["title"] = _controllerField.text;
    task["taskDone"] = false;

    setState(() {
      _tasks.add(task);
    });

    FileUtils.saveFile(_tasks);

    _controllerField.text = "";
  }

  @override
  void initState() {
    super.initState();

    FileUtils.readFile().then((dados) {
      setState(() {
        _tasks = json.decode(dados) ?? [];
      });
    });
  }

  Widget createListTasks(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _lastTaskRemoved = _tasks[index];

        _tasks.removeAt(index);
        FileUtils.saveFile(_tasks);

        final snackbar = SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Tarefa removida!"),
          action: SnackBarAction(
            label: "Desfazer",
            textColor: Colors.green,
            onPressed: () {
              setState(() {
                _tasks.insert(index, _lastTaskRemoved);
              });

              FileUtils.saveFile(_tasks);
            },
          ),
        );

        Scaffold.of(context).showSnackBar(snackbar);
      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            )
          ],
        ),
      ),
      child: CheckboxListTile(
        title: Text(
          _tasks[index]['title'] ?? '',
          style: TextStyle(
            decoration: _tasks[index]['taskDone']
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            fontSize: 18.0,
          ),
        ),
        activeColor: Colors.green,
        value: _tasks[index]['taskDone'],
        onChanged: (valorAlterado) {
          setState(() {
            _tasks[index]['taskDone'] = valorAlterado;
          });

          FileUtils.saveFile(_tasks);
        },
      ),
    );
  }

  _showDialogWidget() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _controllerField,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                labelText: "Digite sua tarefa",
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusColor: Colors.black,
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return "Campo obrigatório";
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            FlatButton(
              color: Colors.red,
              child: Text("Cancelar", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              color: Colors.green,
              child: Text("Salvar", style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _saveTask();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
