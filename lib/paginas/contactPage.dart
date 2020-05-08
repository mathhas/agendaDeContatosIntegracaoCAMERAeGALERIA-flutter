import 'package:flutter/material.dart';
import 'package:project/helpers/contact_helper.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

/*------------------------------------Página que edita e cria contatos------------------------------------*/

//do tipo alterável portanto stful...
class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();

  Contact contact = Contact();
  /*quando a página for chamada na homePage e colocar o contato escolhido
  no parametro dela, automaticamente, atribui o contato passado, a esse contato criado
  para trabalhar com ele nessa página*/

  //recebe o contato dá página principal para trabalhar com ele aqui
  ContactPage({this.contact}); //chaves indicam parâmetro opcional
}

class _ContactPageState extends State<ContactPage> {
  bool _usuarioEditado = false;

  //para deixar o nome do contato nos campos de editar, criar os controladores
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  //para focar no nome se ele estiver vazio(textfield do nome -> botão salvar)
  final _nomeFocado = FocusNode();

  //cria um segundo objeto de contato para trabalhar com ele nessa classe
  Contact _contatoEditado = Contact();

  //como primeira coisa na execução: duplica o objeto contact da classe acima para editar ou criar se for vazio
  @override
  void initState() {
    super.initState();

    if (widget.contact == null) //(widget.objeto) aponta objeto de outra classe
    {
      //cria novo contato
      _contatoEditado = Contact();
    } else {
      //edita o contato existente
      _contatoEditado = Contact.fromMap(widget.contact.dadosToMap());
      /*construtor fromMap pega dados do tipo map e atribui aos atributos do objeto, por isso
      no paramtro dele, o objeto existente de contato é convertido para map (resumidadamente
      esse linha serve pra simplesmente duplicar o objeto de contato que foi passado para essa página)*/

      //controladores para passar os dados nos campos e edição do app
      _nomeController.text = _contatoEditado.name;
      _emailController.text = _contatoEditado.email;
      _phoneController.text = _contatoEditado.phone;
    }
  }

  //interface da página
  @override
  Widget build(BuildContext context) {
    //willPopScope tem como funcionalidade, acessar o botão de voltar para a página anterior na appBar
    //e dizer o que fazer com o formulário (com onWillPop)
    return WillPopScope(
      // o willPopScope tem um child (que ficou todo o código), e o onWillPop que recebe a função que comanda o que fazer ao voltar
      onWillPop: _retornaFormulario,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple[800],
          title: Text(
              _contatoEditado.name == null || _contatoEditado.name.isEmpty
                  ? "Criar contato"
                  : _contatoEditado.name),
          centerTitle: true,
        ),
        //botão de salvar do tipo flutuante
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          backgroundColor: Colors.purple[800],
          onPressed: () {
            if (_contatoEditado.name != null &&
                _contatoEditado.name.isNotEmpty) {
              //retorna para a página anterior (esquema de pilhas), e retorna o objeto alterado ou criado
              Navigator.pop(context, _contatoEditado);
            } else {
              //valida nome vazio
              FocusScope.of(context).requestFocus(_nomeFocado);
            }
          },
        ),
        //corpo da página
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                // opção de adicionar imagem clicando na imagem
                GestureDetector(
                  child: Container(
                    height: 140.0,
                    width: 140.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _contatoEditado.img == null ||
                                _contatoEditado.img.isEmpty
                            ? AssetImage("images/person.png")
                            : FileImage(
                                File(_contatoEditado.img),
                              ),
                      ),
                    ),
                  ),
                  onTap: () {
                    //bottomShet de camera e galeria para inserir imagem para o contato
                    _imageFromCamOrGalery(context);
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        focusNode:
                            _nomeFocado, //ativa apenas quando tocar no salvar e o nome estiver vazio
                        controller: _nomeController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: "Nome"),
                        //salva alteração e atualiza instantaneamente o nome
                        onChanged: (text) {
                          _usuarioEditado = true;
                          setState(() {
                            //usando setState para atualizar a appBar com o nome
                            _contatoEditado.name = text;
                          });
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "E-Mail"),
                          onChanged: (text) {
                            _usuarioEditado = true;
                            _contatoEditado.email = text;
                          },
                          //muda teclado para o tipo de email
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), labelText: "Phone"),
                          onChanged: (text) {
                            _usuarioEditado = true;
                            _contatoEditado.phone = text;
                          },
                          //muda teclado para o tipo de números
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

//--------------------------------------------------------------- funções-auxiliares

  Future<bool> _retornaFormulario() async {
    // se o usuário fizer alteração no formulário
    if (_usuarioEditado) {
      //cria a alertDialog nativa
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Descartar Alterações?"),
            content: Text("Deseja realmente descartar as Alterações feitas?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  //quando clicado, volta para a edição dos dados
                  Navigator.pop(context);
                },
                //titulo do flatButton
              ),
              FlatButton(
                child: Text("Sim"),
                onPressed: () {
                  //volta para a homePage
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  //bottomSheet de opção entre escolher imagem da camera ou da galeria
  void _imageFromCamOrGalery(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Column(
                //abre o bottomSheet do tamanho dos flatButtons somados
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      onPressed: () {
                        //integra com a camera
                        ImagePicker.pickImage(source: ImageSource.camera)
                            .then((file) {
                          setState(() {
                            //passa o caminho do arquivo para o contato
                            _contatoEditado.img = file.path;
                            //fecha o buttonSheet
                            Navigator.pop(context);
                          });
                        });
                      },
                      child: Text(
                        "Câmera",
                        style: TextStyle(
                            fontSize: 22.0,
                            color: Colors.purple[800],
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      onPressed: () {
                        //integra com a galeria
                        ImagePicker.pickImage(source: ImageSource.gallery)
                            .then((file) {
                          setState(() {
                            //Passa o caminho do arquivo para o contato
                            _contatoEditado.img = file.path;

                            //fecha o bottomSheet
                            Navigator.pop(context);
                          });
                        });
                      },
                      child: Text(
                        "Galeria",
                        style: TextStyle(
                            fontSize: 22.0,
                            color: Colors.purple[800],
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        });
  }
}
