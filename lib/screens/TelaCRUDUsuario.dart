import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/controller/UsuarioController.dart';
import 'package:tcc_3/model/Usuario.dart';

class TelaCRUDUsuario extends StatefulWidget {
  final Usuario usuario;

  final DocumentSnapshot snapshot;

  TelaCRUDUsuario({this.usuario, this.snapshot});

  @override
  _TelaCRUDUsuarioState createState() =>
      _TelaCRUDUsuarioState(usuario: usuario, snapshot: snapshot);
}

class _TelaCRUDUsuarioState extends State<TelaCRUDUsuario> {
  //variavel que permite o onPressed do botao entrar acionar o validador dos campos
  final _validadorCampos = GlobalKey<FormState>();

  Usuario usuario;
  final DocumentSnapshot snapshot;

  _TelaCRUDUsuarioState({this.usuario, this.snapshot});

  Usuario _usuarioEditado = Usuario();
  UsuarioController _controllerUser = UsuarioController();
  Cores _cores = Cores();

  String _nomeTela;
  final _controllerNome = TextEditingController();
  final _controllerCPF = TextEditingController();
  final _controllerEmail = TextEditingController();
  final _controllerSenha = TextEditingController();
  bool _existeCadastro;
  bool _existeEmail;
  bool _cpfValido;
  bool _novoCadastro;

  @override
  void initState() {
    super.initState();
    if (usuario != null) {
      _novoCadastro = false;
      _nomeTela = "Editar Usuário";
      _controllerNome.text = usuario.getNome;
      _controllerCPF.text = usuario.getCPF;
      _controllerEmail.text = usuario.getEmail;
    } else {
      _nomeTela = "Cadastrar Usuário";
      _novoCadastro = true;
      usuario = Usuario();
      usuario.setAtivo = true;
      usuario.setPrimeiroLogin = true;
      usuario.setEhAdm = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UsuarioController>(
      builder: (context, child, model) {
        if (_controllerUser.carregando)
          return Center(
            child: CircularProgressIndicator(),
          );
        return Scaffold(
            appBar: AppBar(
              title: Text(_nomeTela),
              centerTitle: true,
              actions: [
                PopupMenuButton(
                  itemBuilder: (BuildContext bc) => [
                    PopupMenuItem(
                        child: Text("Desbloquear"), value: "/desbloquear"),
                    PopupMenuItem(
                        child: Text("Trocar senha"), value: "/trocarsenha"),
                  ],
                  onSelected: (value) {
                    if (value == "/desbloquear") {
                      print(usuario.getNome);
                      usuario.setBloqueado = false;
                      Map<String, dynamic> dadosUsuario =
                        _controllerUser.converterParaMapa(usuario);
                      _controllerUser.salvarUsuario(
                          dadosUsuario, usuario.getID);
                    }
                  },
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
                child: Icon(Icons.save),
                backgroundColor: Colors.blue,
                onPressed: () async {
                  //Antes de verificar a existencia ou fazer validação
                  //verifica se a informação existe
                  //para evitar que dentro do metodo ocorra nullpointerexception
                  if (_controllerCPF.text.isNotEmpty) {
                    _existeCadastro =
                        await _controllerUser.verificarExistenciaCPF(usuario);
                  }

                  if (_controllerEmail.text.isNotEmpty) {
                    _existeEmail =
                        await _controllerUser.verificarExistenciaEmail(usuario);
                  }

                  if (_controllerCPF.text.isNotEmpty) {
                    _cpfValido = _controllerUser.validarCPF(usuario.getCPF);
                  }

                  if (_validadorCampos.currentState.validate()) {
                    Map<String, dynamic> dadosUsuario =
                        _controllerUser.converterParaMapa(usuario);

                    if (_novoCadastro) {
                      _controllerUser.cadastrarUsuario(
                          dadosUser: dadosUsuario,
                          senha: _controllerSenha.text,
                          cadastradoSucesso: _sucesso,
                          cadastroFalhou: _falha);
                    } else {
                      _controllerUser.salvarUsuario(
                          dadosUsuario, usuario.getID);
                      _sucesso();
                    }
                  }
                }),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(8.0),
              child: Container(
                child: Form(
                    key: _validadorCampos,
                    child: Column(
                      children: <Widget>[
                        _criarCampoTexto("Nome Completo", _controllerNome,
                            TextInputType.text, false, true, 150),
                        _criarCampoTexto("CPF", _controllerCPF,
                            TextInputType.number, false, true, 11),
                        _criarCampoTexto(
                            "E-mail",
                            _controllerEmail,
                            TextInputType.emailAddress,
                            false,
                            _novoCadastro,
                            40),
                        _novoCadastro
                            ? _criarCampoTexto("Senha", _controllerSenha,
                                TextInputType.text, true, true, 20)
                            : Container(),
                        _criarCampoCheckBoxAdm(),
                        _criarCampoCheckBoxAtivo(),
                        _criarCampoCheckBoxBloqueado()
                      ],
                    )),
              ),
            ));
      },
    );
  }

  Widget _criarCampoTexto(String nome, TextEditingController controller,
      TextInputType tipo, bool obscured, bool enabled, int tamanho) {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: controller,
          keyboardType: tipo,
          obscureText: obscured,
          enabled: enabled,
          maxLength: tamanho,
          validator: (text) {
            if (text.isEmpty) return "Este campo deve ser informado";
            if (nome == "CPF" && text.isNotEmpty && _cpfValido == false)
              return "CPF inválido!";
            if (nome == "CPF" && text.isNotEmpty && _existeCadastro == true)
              return "Já existe outro usuário com o mesmo CPF, verifique!";
            if (_novoCadastro) {
              if (nome == "E-mail" && text.isNotEmpty && _existeEmail == true)
                return "Já existe outro usuário com o mesmo E-mail, verifique!";
              if (nome == "E-mail" && !text.contains("@"))
                return "E-mail inválido!";
              if (nome == "E-mail" && !text.contains(".com"))
                return "E-mail inválido!";
            }
            if (nome == "Senha" && text.length < 6)
              return "A senha deve conter no mínimo 6 caracteres";
          },
          decoration: InputDecoration(
              labelText: nome,
              labelStyle: TextStyle(
                  color: Colors.blueGrey, fontWeight: FontWeight.w400)),
          style: TextStyle(color: _cores.corCampo(enabled)),
          onChanged: (texto) {
            switch (nome) {
              case "Nome Completo":
                {
                  usuario.setNome = texto.toUpperCase();
                }
                break;

              case "CPF":
                {
                  usuario.setCPF = texto.toUpperCase();
                }
                break;

              case "E-mail":
                {
                  usuario.setEmail = texto.toLowerCase();
                }
                break;
            }
          },
        ),
        SizedBox(
          height: 3.0,
        ),
      ],
    );
  }

  Widget _criarCampoCheckBoxAdm() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: usuario.getEhAdm == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  usuario.setEhAdm = true;
                } else {
                  usuario.setEhAdm = false;
                }
              });
            },
          ),
          Text(
            "Administrador?",
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  Widget _criarCampoCheckBoxAtivo() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: usuario.getAtivo == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  usuario.setAtivo = true;
                } else {
                  usuario.setAtivo = false;
                }
              });
            },
          ),
          Text(
            "Ativo?",
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  Widget _criarCampoCheckBoxBloqueado() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
              value: usuario.getBloqueado == true,
              onChanged: true ? null : null),
          Text(
            "Bloqueado?",
            style: TextStyle(fontSize: 18.0, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _sucesso() {
    Navigator.of(context).pop();
  }

  void _falha() {
    print("erro");
  }
}
