import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contatoTabela = "tbContato";
final String idColuna = "ID";
final String nomeColuna = "Nome";
final String emailColuna = "Email";
final String telefoneColuna = "Telefone";
final String imagemColuna = "Imagem";

class ContatoHelper{
  static final ContatoHelper _instance = ContatoHelper.internal();
  factory ContatoHelper() => _instance;
  ContatoHelper.internal();

  Database _db;

  Future<Database> get db async{
    if (_db != null) {
      return _db;
    } else{
      _db = await iniciarDb();
      return _db;
    }
  }

  Future<Database> iniciarDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contato.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute("CREATE TABLE $contatoTabela($idColuna INTEGER PRIMARY KEY, $nomeColuna TEXT, $emailColuna TEXT,"
          "$telefoneColuna TEXT, $imagemColuna TEXT)");

    });
  }

  Future<Contato> salvarContato(Contato contato) async{
    Database dbContato = await db;
    contato.id = await dbContato.insert(contatoTabela, contato.toMap());
    return contato;
  }

  Future<Contato> obterContato(int ID) async{
    Database dbContato = await db;
    List<Map> maps = await dbContato.query(contatoTabela,
        columns: [idColuna, nomeColuna, emailColuna, telefoneColuna, imagemColuna],
        where: "$idColuna = ?",
        whereArgs: [ID]);
    if (maps.length > 0) {
      return Contato.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future <List> obterTodosContatos() async{
    Database dbContato = await db;
    List listaMaps = await dbContato.rawQuery("SELECT * FROM $contatoTabela");
    List<Contato> listaContatos = List();
    for (Map m in listaMaps){
      listaContatos.add(Contato.fromMap(m));
    }
    return listaContatos;
  }

  Future<int> deletarContato(int ID) async{
    Database dbContato = await db;
    return await dbContato.delete(contatoTabela, where: "$idColuna = ?", whereArgs: [ID]);
  }

  Future<int> atualizarContato(Contato contato) async{
    Database dbContato = await db;
    return await dbContato.update(contatoTabela, contato.toMap(), where: "$idColuna = ?", whereArgs: [contato.id]);
  }

  Future<int> obterContagem() async{
    Database dbContato = await db;
    return Sqflite.firstIntValue(await dbContato.rawQuery("SELECT COUNT(*) FROM $contatoTabela"));
  }

  Future fecharConexao() async{
    Database dbContato = await db;
    dbContato.close();
  }
}

class Contato{
  int id;
  String nome;
  String email;
  String telefone;
  String imagem;

  Contato();

  Contato.fromMap(Map map){
    id = map[idColuna];
    nome = map[nomeColuna];
    email = map[emailColuna];
    telefone = map[telefoneColuna];
    imagem = map[imagemColuna];
  }

  Map toMap(){
    Map<String, dynamic>map = {
    nomeColuna: nome,
    emailColuna: email,
    telefoneColuna: telefone,
    imagemColuna: imagem,
    };
    if (id != null){
      map[idColuna] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contato(ID $id, Nome: $nome, Email: $email, Telefone: $telefone, Imagem: $imagem";
  }


}