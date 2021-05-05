import 'dart:io';
import 'dart:async';

import 'package:easy_contatos/helpers/contato_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ContatoPage extends StatefulWidget {
  final Contato contato;

  ContatoPage({this.contato});

  @override
  _ContatoPageState createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  Contato _editorContato;
  final _nomeControlador = TextEditingController();
  final _nomeFocus = FocusNode();
  final _emailControlador = TextEditingController();
  final _telefoneControlador = TextEditingController();
  bool _contatoEditado = false;

  @override
  void initState() {
    super.initState();
    if (widget.contato == null){
      _editorContato = Contato();
    } else {
      _editorContato = Contato.fromMap(widget.contato.toMap());
      _nomeControlador.text = _editorContato.nome;
      _emailControlador.text = _editorContato.email;
      _telefoneControlador.text = _editorContato.telefone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requisitarPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editorContato.nome ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if (_editorContato.nome != null && _editorContato.nome.isNotEmpty) {
              Navigator.pop(context, _editorContato);
            } else {
              FocusScope.of(context).requestFocus(_nomeFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(

                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: _editorContato.imagem != null ?
                        FileImage(File(_editorContato.imagem)) :
                        AssetImage("images/contato_vazio.jpg")
                    ),
                  ),
                ),
                onTap: (){
                  ImagePicker.platform.pickImage(source: ImageSource.camera).then((value){
                    if (value == null) return;
                    setState(() {
                      _editorContato.imagem = value.path;
                    });
                  });
                },
              ),
              TextField(decoration: InputDecoration(labelText: "Nome", labelStyle: TextStyle(color: Colors.black, fontSize: 20.0)),
                controller: _nomeControlador,
                focusNode: _nomeFocus,
                textAlign: TextAlign.start,
                onChanged: (texto){
                  _contatoEditado = true;
                  setState(() {
                    _editorContato.nome = texto;
                  });
                },
              ),
              TextField(decoration: InputDecoration(labelText: "Email", labelStyle: TextStyle(color: Colors.black, fontSize: 20.0)),
                controller: _emailControlador,
                textAlign: TextAlign.start,
                onChanged: (texto){
                  _contatoEditado = true;
                  _editorContato.email = texto;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(decoration: InputDecoration(labelText: "Telefone", labelStyle: TextStyle(color: Colors.black, fontSize: 20.0)),
                controller: _telefoneControlador,
                textAlign: TextAlign.start,
                onChanged: (texto){
                  _contatoEditado = true;
                  _editorContato.telefone = texto;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requisitarPop(){
    if (_contatoEditado == true) {
      showDialog(context: context,
        builder: (context){
        return AlertDialog(
          title: Text("Descartar Alterações?"),
          content: Text("As alteraçoes serão perdidas."),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancelar"),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Sim"),
              onPressed: (){
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
