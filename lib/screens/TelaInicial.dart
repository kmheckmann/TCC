import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tcc_3/controller/UsuarioController.dart';
import 'package:tcc_3/model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tcc_3/screens/HomeScreen.dart';
import 'package:tcc_3/screens/TelaTrocarSenha.dart';

class TelaInicial extends StatefulWidget {
  @override
  _TelaInicialState createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final _scaffold = GlobalKey<ScaffoldState>();

  //variavel que permite o onPressed do botao entrar acionar o validador dos campos
  final _validadorCampos = GlobalKey<FormState>();
  final _controllerEmail = TextEditingController();
  final _controllerSenha = TextEditingController();
  UsuarioController _usuarioController = UsuarioController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffold,
        appBar: AppBar(
          title: Text("Vale Distribuidora"),
          centerTitle: true,
        ),
        //ScopedModelDescendant eh para essa classe conseguir ter acesso e ser influenciada pelo
        //que ocorre dentro da classe usuario
        body: ScopedModelDescendant<UsuarioController>(
          builder: (context, child, model) {
            if (model.carregando)
              return Center(
                child: CircularProgressIndicator(),
              );

            return Form(
              key: _validadorCampos,
              child: ListView(
                //ListView para adicionar scroll quando abrir o teclado em vez de ocultar os campos
                padding: EdgeInsets.all(16.0),
                children: <Widget>[
                  TextFormField(
                    controller: _controllerEmail,
                    decoration: InputDecoration(
                      hintText: "E-mail",
                    ),
                    keyboardType: TextInputType.emailAddress,
                    //faz uma verificao simples do texto informado no campo
                    validator: (text) {
                      if (text.isEmpty || !text.contains("@"))
                        return "E-mail inválido!";
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    controller: _controllerSenha,
                    decoration: InputDecoration(hintText: "Senha"),
                    obscureText: true,
                    validator: (text) {
                      if (text.isEmpty || text.length < 6)
                        return "Senha inválida!";
                    },
                  ),
                  SizedBox(
                    height: 2.0,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FlatButton(
                      onPressed: () {
                        if (_controllerEmail.text.isEmpty) {
                          _scaffold.currentState.showSnackBar(SnackBar(
                            content:
                                Text("Informe o email para recuperar a senha!"),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          ));
                        } else {
                          model
                              .recuperarSenha(_controllerEmail.text);
                          _scaffold.currentState.showSnackBar(SnackBar(
                            content: Text(
                                "Instruções para recuperar a senha foram enviadas para seu email!"),
                            backgroundColor: Theme.of(context).primaryColor,
                            duration: Duration(seconds: 3),
                          ));
                        }
                      },
                      child: Text("Esqueci a senha",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16.0)),
                      //Para o texto ficar alinhado certinho com o final do campo "senha"
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  SizedBox(
                    //para o botao ficar mais largo
                    height: 44.0,
                    child: RaisedButton(
                      child: Text(
                        "Entrar",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      onPressed: () {
                        if (_validadorCampos.currentState.validate()) {
                          model.efetuarLogin(
                              email: _controllerEmail.text,
                              senha: _controllerSenha.text,
                              sucessoLogin: _sucessoLogin,
                              falhaLogin: _falhaLogin,
                              emailNaoVerificado: _emailNaoVerificado,
                              primeiroLogin: _primeiroLogin,
                              usuarioInativo: _usuarioInativo
                              );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }

  void _falhaLogin() {
    _scaffold.currentState.showSnackBar(SnackBar(
      content: Text("Email e/ou senha inválidos!"),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ));
  }

  void _emailNaoVerificado() {
    _scaffold.currentState.showSnackBar(SnackBar(
      content: Text("Email não verificado!"),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ));
  }

  void _usuarioInativo() {
    _scaffold.currentState.showSnackBar(SnackBar(
      content: Text("Usuário inativo, entre em contato com o administrador"),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ));
  }

  void _sucessoLogin() {
    _controllerSenha.text = "";
    _controllerEmail.text = "";
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  void _primeiroLogin() {
    _controllerSenha.text = "";
    _controllerEmail.text = "";
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => TelaTrocarSenha()));
  }
}
