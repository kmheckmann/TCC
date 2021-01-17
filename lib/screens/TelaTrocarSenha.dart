import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/controller/UsuarioController.dart';
import 'package:tcc_3/model/Usuario.dart';
import 'package:tcc_3/screens/HomeScreen.dart';

class TelaTrocarSenha extends StatefulWidget {
  @override
  _TelaTrocarSenhaState createState() => _TelaTrocarSenhaState();
}

class _TelaTrocarSenhaState extends State<TelaTrocarSenha> {
  final _scaffold = GlobalKey<ScaffoldState>();
  final _validadorCampos = GlobalKey<FormState>();
  final _controllerSenha = TextEditingController();

  Usuario usuario;
  Cores _cores = Cores();
  String _novaSenha;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UsuarioController>(
        builder: (context, child, model) {
      return Scaffold(
          key: _scaffold,
          appBar: AppBar(
            title: Text("Troca de Senha"),
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
                      controller: _controllerSenha,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      validator: (text) {
                        if (text.isEmpty) return "Informe a nova senha!";
                        if (text.isNotEmpty && text.length < 6)
                          return "A senha deve conter no mínimo 6 caracteres!";
                        if (!text.contains(new RegExp(r'[A-Z]')))
                          return "A senha deve ter pelo menos uma letra maiúscula!";
                        if (!text.contains(new RegExp(r'[0-9]')))
                          return "A senha deve ter pelo menos um número!";
                        if (!text.contains(new RegExp(r'[a-z]')))
                          return "A senha deve ter pelo menos uma letra minúscula!";
                        if (!text
                            .contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]')))
                          return "A senha deve ter pelo menos um caractere especial!";
                      },
                      decoration: InputDecoration(
                          labelText: "Nova Senha",
                          labelStyle: TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w400)),
                      style: TextStyle(color: _cores.corCampo(true)),
                      onChanged: (texto) {
                        _novaSenha = _controllerSenha.text;
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    SizedBox(
                      //para o botao ficar mais largo
                      height: 44.0,
                      child: RaisedButton(
                        child: Text(
                          "Trocar Senha",
                          style: TextStyle(fontSize: 20.0),
                        ),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () {
                          if (_validadorCampos.currentState.validate()) {
                            model.alterarSenha(_novaSenha);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => HomeScreen()));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ));
    });
  }
}
