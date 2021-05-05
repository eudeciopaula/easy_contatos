import 'dart:io';
import 'package:easy_contatos/helpers/contato_helper.dart';
import 'package:easy_contatos/ui/contato_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContatoHelper helper = ContatoHelper();
  List<Contato> listaContatos = List();

  @override
  void initState() {
    super.initState();
    _obterTodosContatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContato();
        },
        child: Icon(Icons.add, color: Colors.white,),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: listaContatos.length,
          itemBuilder: (context, index){
            return _contatoCartao(context, index);
          }
      ),
    );
  }

  Widget _contatoCartao(BuildContext context, int index){
    return GestureDetector(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: listaContatos[index].imagem != null ?
                          FileImage(File(listaContatos[index].imagem)) :
                          AssetImage("images/contato_vazio.jpg")
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(listaContatos[index].nome ?? "",
                      style: TextStyle(color: Colors.black, fontSize: 22.0, fontWeight: FontWeight.bold,),),
                      Text(listaContatos[index].email ?? "",
                      style: TextStyle(color: Colors.black12, fontSize: 18.0),),
                      Text(listaContatos[index].telefone ?? "",
                        style: TextStyle(color: Colors.black12, fontSize: 18.0),)
                    ],
                  ),
                ),
              ],
            ),
          ),
      ),
      onTap: (){
          _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context){
          return BottomSheet(
            onClosing: (){},
              builder: (context){
                return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: FlatButton(
                            child: Text("Ligar", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                            onPressed: (){
                              launch("tel:${listaContatos[index].telefone}");
                              //launch.call(listaContatos[index].telefone);
                              Navigator.pop(context);
                            },
                          ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: FlatButton(
                          child: Text("Editar", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                          onPressed: (){
                            Navigator.pop(context);
                            _showContato(contato: listaContatos[index]);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: FlatButton(
                          child: Text("Excluir", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                          onPressed: (){
                            setState(() {
                              helper.deletarContato(listaContatos[index].id);
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
          );
        }
    );
  }

  void _showContato({Contato contato}) async {
    final retornoContato = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => ContatoPage(contato: contato,)));

    if (retornoContato != null) {
      if (contato != null) {
        await helper.atualizarContato(retornoContato);
        _obterTodosContatos();
      } else {
        await helper.salvarContato(retornoContato);
        _obterTodosContatos();
      }
    }
  }
  
  void _obterTodosContatos(){
    helper.obterTodosContatos().then((list){
      setState(() {
        listaContatos = list;
        _orderList(OrderOptions.orderaz);
      });
    });
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        listaContatos.sort((a, b) {
          return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        listaContatos.sort((a, b) {
          return b.nome.toLowerCase().compareTo(a.nome.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }
}
