import 'package:flutter/material.dart';
import 'package:project/helpers/contact_helper.dart';
import 'dart:io';
import 'package:project/paginas/contactPage.dart';
import 'package:url_launcher/url_launcher.dart';

//ordenar lista (feito em 3 etapas, (1-essa da declaração do enum), (2-a criação do icone e atribuição da tarefa a ele) e (3-a criação da func que fará a ordenação)):
enum OrdenaListaOpcoes { orderaz /*constantes*/, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //instancia da classe que manipula o DB
  ContactHelper helper = ContactHelper();
  /*Como foi usado o padrão singleton para contruir essa classe
  por mais que tenham varias instancias de contactHelper, todas elas apontam para o mesmo e unico objeto
  o que foi criado e instanciado dentro da classe*/

  //Lista de contatos
  List<Contact> contatos = List();

  //teste, debug FUNC QUE INICIA ASSIM QUE A PAGINA INICIA
  @override
  void initState() {
    super.initState();
    // //cadastrando
    // Contact contatoEU = new Contact();
    // //contatoEU.name = "";
    // //contatoEU.email = "";
    // //contatoEU.phone = "4545454";
    // //contatoEU.img = "";

    // helper.saveContact(contatoEU);

    // helper.getAllContacts().then((list) {
    //   print(list);
    // });

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[800],
        title: Text("Agenda de Contatos"),
        centerTitle: true,
        //criação do botão de ordenar
        actions: <Widget>[
          PopupMenuButton<OrdenaListaOpcoes>(
            itemBuilder: (context) => <PopupMenuEntry<OrdenaListaOpcoes>>[
              const PopupMenuItem<OrdenaListaOpcoes>(
                child: Text("Ordenar de A-Z"),
                value: OrdenaListaOpcoes.orderaz,
              ),
              const PopupMenuItem<OrdenaListaOpcoes>(
                child: Text("Ordenar de Z-A"),
                value: OrdenaListaOpcoes.orderza,
              ),
            ],
            onSelected: _ordenarLista,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      //adicionando o botão flutuante de "+" para **CRIAR NOVO CONTATO**
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //direciona para a página de contato. Nesse caso para criar.
          _mostraJanelaDeContato();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple[800],
      ),
      //cria o corpo, que é a lista de contatos
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount:
            contatos.length, //sem tamanho a lista n sabe até onde ir e buga
        itemBuilder: (context, index) {
          return _exibeListaContatos(context, index);
        },
      ),
    );
  }

//--------------------------------------------------------------- funções-auxiliares

//pega os dados de contato do DB, e retorna o card do contato
  Widget _exibeListaContatos(BuildContext context, int index) {
    return (GestureDetector(
      onTap: () {
        //ao tocar em algum item da lista aparece um buttomSheet com opções do que fazer
        _mostraOpcoes(context, index);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              //-----------------------------PRIMEIRO, a imagem a esquerda no card
              Container(
                //dimençoes da img
                height: 80.0,
                width: 80.0,
                //decoração para estabelecer a forma que a img será apresentada
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    //se tiver img apresenta, senão mostra img padrao
                    image: contatos[index].img != null
                        ? FileImage(File(contatos[index].img))
                        : AssetImage("images/person.png"),
                  ),
                ),
              ),
              //-----------------------------SEGUNDO, nome, email e telefone do contato
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  //para os dados ficarem alinhados na pargem esquerda
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      //se...
                      contatos[index].name == null ||
                              contatos[index].name.isEmpty
                          ? "(Sem Nome)"
                          : contatos[index].name,
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      contatos[index].email == null ||
                              contatos[index].email.isEmpty
                          ? "(Sem e-mail)"
                          : contatos[index].email,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      contatos[index].phone == null ||
                              contatos[index].phone.isEmpty
                          ? "(Sem Telefone)"
                          : contatos[index].phone,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  void _mostraJanelaDeContato({Contact contato}) async {
    //direciona para a página contactPage e salva o contato alterado ou criado
    final contatoRetornado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(
          contact: contato,
        ),
      ),
    );

    //salva no DB o contato retornado
    if (contatoRetornado != null) {
      if (contato != null) {
        //caso em que se envia um contato não vazio e retonra um nao vazio (alterado ou nao)
        await helper.updateContact(contatoRetornado);
      } else {
        //caso que cria contato novo
        await helper.saveContact(contatoRetornado);
      }
      //atualiza a lista de contatos após alteração ou criação
      _getAllContacts();
    }
  }

  //lê todos contatos do DB e salva na lista de contatos
  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contatos = list;
      });
    });
  }

  //mostra o bottomSheet "ligar" "editar" "excluir"
  void _mostraOpcoes(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          //*ao executar sem o onClosing bugou*
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                //para BottomSheet ficar do tamanho dos flatButtons
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  //criada a coluna de exibição de botoes, inserir quais:
                  Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                    child: FlatButton(
                      child: Text(
                        "Ligar",
                        style: TextStyle(
                            color: Colors.purple[800],
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        //integra com telefone e passa o número
                        launch("tel:${contatos[index].phone}");

                        //fecha o buttomSheet
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                    child: FlatButton(
                      child: Text(
                        "Editar Contato",
                        style: TextStyle(
                            color: Colors.purple[800],
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        //fecha o buttomSheet
                        Navigator.pop(context);

                        //edita contato
                        _mostraJanelaDeContato(contato: contatos[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                    child: FlatButton(
                      child: Text(
                        "Excluir Contato",
                        style: TextStyle(
                            color: Colors.purple[800],
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          //deleta do DB o contato pelo ID
                          helper.deleteContact(contatos[index].id);

                          //deleta da list (na ram)
                          contatos.removeAt(index);

                          //sai do buttomSheet
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _ordenarLista(OrdenaListaOpcoes result) {
    switch (result) {
      case OrdenaListaOpcoes.orderaz:
        contatos.sort((a, b) {
          //a e b são objetos do tipo contato, e herdam consequentemente as características de objeto...
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrdenaListaOpcoes.orderza:
        contatos.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    //para atualizar lista a cada vez que chamar a função (escolher um tipo de ordenamento)
    setState(() {});
  }
}
