import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyHomePage(),
  ));
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _itens = [];

  Future<File> _getFile() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    return File('${tempDir.path}/dados.json');
  }

  _saveFile() async {
    var file = await _getFile();

    Map<String, dynamic> task = Map();

    task["title"] = "Ir ao mercado";
    task["realizada"] = false;

    _itens.add(task);

    String dados = json.encode(_itens);
    file.writeAsString(dados);
  }

  _readFile() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _readFile().then((dados) {
      setState(() {
        _itens = json.decode(dados);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _itens.length,
              itemBuilder: (ctx, index) {
                var teste = _itens[index];

                return ListTile(title: Text(_itens[index]));
              },
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Increment Task',
        label: Text('Adicionar tarefa'),
        icon: Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Adicionar Tarefa'),
                  content: TextField(
                    decoration: InputDecoration(labelText: "Digite sua tarefa"),
                    onChanged: (text) {},
                  ),
                  actions: [
                    FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar'),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _saveFile();
                      },
                      child: Text('Salvar'),
                    ),
                  ],
                );
              });
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
