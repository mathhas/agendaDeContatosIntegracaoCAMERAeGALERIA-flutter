import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

//nomes das colunas no DB
final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

//classe que trata do DB funcionalidades de CRUD
class ContactHelper {
  //classe utilizando o padrão singleton (permite apenas uma instancia do objeto e é feito na própria classe)
  //exelente para apontar para o DB independente de quantas instancias sejam feitas
  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;

  ContactHelper.internal(); //declara o método internal para ser identificado

  Database _db;

  //inicializa ou cria o db se nao existir e o retorna (get é usado para pegar esse "db")
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await iniciaDB();
      return _db;
    }
  }

  Future<Database> iniciaDB() async {
    //local(path == caminho) aonde o DB está
    final String databasesPath =
        await getDatabasesPath(); //await pois nao retorna instantanemanete, necessita ser assyncrono
    //caminho completo do DB
    final String path = join(databasesPath, "contactsnew.db");

    //abre o db
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");
    });
  }

  //salva um contato no DB
  Future<Contact> saveContact(Contact contact) async {
    //pega o DB
    Database dbContact = await db;

    //ao passar os dados para o db, e gerar o id, o id é passado para o contato
    contact.id = await dbContact.insert(contactTable, contact.dadosToMap());

    return contact;
  }

  //Busca o contato do id indicado
  Future<Contact> getContactById(int id) async {
    //pega o DB
    Database dbContact = await db;

    //recebe o contato de acordo com o id indicado
    List<Map> dadosDoContato = await dbContact.query(
        contactTable, //nome da table para fazer a busca
        columns: [
          idColumn,
          nameColumn,
          emailColumn,
          phoneColumn,
          imgColumn
        ], // quais colunas retornar nessa busca de query
        where: "$idColumn = ?", //retorna onde o id igual ao inidicado
        whereArgs: [id]); //argumento, o id a indicar acima

    //se encontrar um contato com o id indicado o retorna
    if (dadosDoContato.length > 0) {
      return Contact.fromMap(dadosDoContato.first);
    } else {
      return null;
    }
  }

  //deleta um contato
  Future<int> deleteContact(int id) async {
    //pega o db
    Database dbContact = await db;

    //deleta o contato e retorna se deu certo ou errado com um inteiro
    return await dbContact.delete(contactTable, //nome da tabela no db
        where: "$idColumn = ?", // aonde o id for igual ao fornecido
        whereArgs: [id] // argumento a passar na interrogação
        );
  }

  //Atualiza contato
  Future<int> updateContact(Contact contact) async {
    //pega o db
    Database dbContact = await db;

    //atualiza o contato no id do contato passado para a func e retorna se deu certo ou nao com um int
    return await dbContact.update(contactTable, contact.dadosToMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  //busca todos os contatos e salva numa lista de contatos
  Future<List> getAllContacts() async {
    //pega o db
    Database dbContact = await db;

    //pega todos os contatos
    List listaMapsContatos =
        await dbContact.rawQuery("SELECT * FROM $contactTable");

    //cria uma lista do tipo contatos para passar os contatos para ela
    List<Contact> listaContatos = List();

    //transoforma os maps da lista de mapsContatos em contatos e passa para a lista de contatos
    for (Map m in listaMapsContatos) {
      listaContatos.add(Contact.fromMap(m));
    }
    return listaContatos;
  }
}

class Contact {
  //Atributos
  int id;
  String name;
  String email;
  String phone;
  String img; //local aonde foi armezanada a imagem no dispositivo

  //Métodos

  Contact();

  //construtor que recebe um Map com os dados e atribui a cada atributo de contato
  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  //transformar os dados em um map para retornar
  Map dadosToMap() {
    Map<String, dynamic> map = {
      // dois pontos pois é do tipo final
      nameColumn: this.name,
      emailColumn: this.email,
      phoneColumn: this.phone,
      imgColumn: this.img
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  //sobrescreve o método da classe String para retornar os dados de forma legível quando chamar o método
  String toString() {
    return ("Contato: (id: $id, nome: $name, email: $email, phone: $phone, img: $img)");
  }
}
