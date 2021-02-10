import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tcc_3/model/Usuario.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cpfcnpj/cpfcnpj.dart';

class UsuarioController extends Model {
  UsuarioController();

  Usuario usuario = Usuario();

  //declarado so para nao escrever FirebaseAuth.instance toda hora
  FirebaseAuth _autenticar = FirebaseAuth.instance;

  //armazena o usuario que esta logado, se nao tiver usuario fica null, se tiver, contem o id e infos basicas
  User usuarioFirebase;

  //armazena o novo usuario criado

  //ira armazenar os dados importantes do usuario
  Map<String, dynamic> dadosUsuarioAtual = Map();
  Map<String, dynamic> dadosNovoUsuario = Map();

  //indica quando algo esta sendo processado dentro da classe usuario
  bool carregando = false;

  //converte para mapa para ser possível salvar no banco
  Map<String, dynamic> converterParaMapa(Usuario user) {
    return {
      "nome": user.getNome,
      "cpf": user.getCPF,
      "email": user.getEmail,
      "ehAdm": user.getEhAdm,
      "ativo": user.getAtivo,
      "primeiroLogin": user.getPrimeiroLogin
    };
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _carregarDadosUsuario();
  }

  //VoidCallBack uma funcao passada que sera chamado de dentro do metodo
  void cadastrarUsuario(
      {@required Map<String, dynamic> dadosUser,
      @required String senha,
      @required VoidCallback cadastradoSucesso,
      @required VoidCallback cadastroFalhou}) {
    carregando = true;
    _autenticar
        .createUserWithEmailAndPassword(
            email: dadosUser["email"], password: senha)
        .then((user) async {
      user.user.sendEmailVerification();
      //se der certo a criacao do usuario, pego os dados e salvo no firebase
      await salvarUsuario(dadosUser, user.user.uid);
      cadastradoSucesso();
      carregando = false;
    }).catchError((erro) {
      cadastroFalhou();
      carregando = false;
    });
  }

//Faz com que o login do usuario seja efetuado no sistema
  void efetuarLogin(
      {@required String email,
      @required String senha,
      @required VoidCallback sucessoLogin,
      @required VoidCallback falhaLogin,
      @required VoidCallback emailNaoVerificado,
      @required VoidCallback primeiroLogin,
      @required VoidCallback usuarioInativo}) async {
    carregando = true;
    //"avisar" todas as classes coonfiguradas para receber notificação sobre as mudancas que ocorreram no usuario
    notifyListeners();

//Usa uma propriedade nativa do firebase para fazer a autenticação
    _autenticar
        .signInWithEmailAndPassword(email: email, password: senha)
        .then((usuario) async {
      User u = usuario.user;

      if (u.emailVerified) {
        //Carrega os dados do usuario
        await _carregarDadosUsuario();
        if (dadosUsuarioAtual["ativo"]) {
          if (!dadosUsuarioAtual["primeiroLogin"]) {
            sucessoLogin();
          } else {
            primeiroLogin();
          }
        } else {
          usuarioInativo();
        }
      } else {
        emailNaoVerificado();
      }
      carregando = false;
      notifyListeners();
    }).catchError((e) {
      falhaLogin();
      carregando = false;
      notifyListeners();
    });
  }

  Future<Null> salvarUsuario(
      Map<String, dynamic> dadosUsuario, String id) async {
    this.dadosNovoUsuario = dadosUsuario;
    await Firestore.instance
        .collection("usuarios")
        .document(id)
        .setData(dadosUsuario);
  }

//Verifica se existe algum usuario logado
  bool usuarioLogado() {
    return usuarioFirebase != null;
  }

//Efetua o logou to usuário no sistema
  void sair() async {
    await _autenticar.signOut();
    dadosUsuarioAtual = Map();
    usuarioFirebase = null;
    notifyListeners();
  }

//utiliza uma propriedade nativa do firebase que dispara um email para redefinir a senha
  void recuperarSenha(String email) {
    _autenticar.sendPasswordResetEmail(email: email);
  }

  //metodo utilizado na tela TrocarSenha, após o primeiro login do user
  void alterarSenha(String senha) {
    usuarioFirebase.updatePassword(senha);
    dadosUsuarioAtual["primeiroLogin"] = false;
    usuario.setPrimeiroLogin = false;
    salvarUsuario(dadosUsuarioAtual, usuarioFirebase.uid);
  }

//Carrega todos os dados do usuário que efetuou o login
//Notifica todas as classes que estão configurada para receber qualquer alteração do usuario
  Future<Null> _carregarDadosUsuario() async {
    if (usuarioFirebase == null)
      usuarioFirebase = await _autenticar.currentUser;

    if (usuarioFirebase != null) {
      if (dadosUsuarioAtual["name"] == null) {
        DocumentSnapshot docUsuario = await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(usuarioFirebase.uid)
            .get();
        dadosUsuarioAtual = docUsuario.data();
        dadosUsuarioAtual["id"] = docUsuario.id;
        dadosUsuarioAtual["primeiroLogin"] = docUsuario.data()["primeiroLogin"];
        dadosNovoUsuario = docUsuario.data();
        dadosNovoUsuario["id"] = docUsuario.id;
        dadosNovoUsuario["primeiroLogin"] = docUsuario.data()["primeiroLogin"];
      }
      notifyListeners();
    }
  }

//Obtem os dados do usuário utilizando o CPF deste
  Future<Usuario> obterUsuarioPorCPF(String cpf) async {
    Usuario u;
    if (cpf.contains(" - ")) {
      var array = cpf.split(" - ");
      cpf = array[1];
    }
    //Acessa a collection
    CollectionReference ref = Firestore.instance.collection('usuarios');
    //Obtem da collection o registro onde o CPF seja igual ao que foi passado por parametro
    QuerySnapshot eventsQuery =
        await ref.where("cpf", isEqualTo: cpf).getDocuments();

    //Só existirá um usuário para cada CPF,
    //então pega os dados desde usuário retornado da collection e atribui a uma variavel
    eventsQuery.documents.forEach((document) {
      u = Usuario.buscarFirebase(document);
      u.setID = document.documentID;
    });
    return Future.value(u);
  }

  Future<bool> verificarExistenciaCPF(Usuario user) async {
    bool existeCad = false;
    //Busca todas usuarios
    CollectionReference ref = Firestore.instance.collection("usuarios");
    //Nos users cadastrados verifica se existe algum com o mesmo cpf informado no cadastro atual
    //se houver atribui true para a variável _existeCadastro
    QuerySnapshot eventsQuery =
        await ref.where("cpf", isEqualTo: user.getCPF).getDocuments();
    eventsQuery.documents.forEach((document) {
      if (user.getCPF == document.data()["cpf"] &&
          user.getID != document.documentID) {
        existeCad = true;
      }
    });
    return Future.value(existeCad);
  }

  Future<bool> verificarExistenciaEmail(Usuario user) async {
    bool existeEmail = false;
    //Busca todas usuarios
    CollectionReference ref = Firestore.instance.collection("usuarios");
    //Nos users cadastrados verifica se existe algum com o mesmo cpf informado no cadastro atual
    //se houver atribui true para a variável _existeCadastro
    QuerySnapshot eventsQuery =
        await ref.where("email", isEqualTo: user.getEmail).getDocuments();
    eventsQuery.documents.forEach((document) {
      if (user.getEmail == document.data()["email"] &&
          user.getID != document.documentID) {
        existeEmail = true;
      }
    });
    return Future.value(existeEmail);
  }

  bool validarCPF(String cpf) {
    bool cpfValido;
    CPF.format(cpf);
    if (CPF.isValid(cpf)) {
      cpfValido = true;
    } else {
      cpfValido = false;
    }
    return cpfValido;
  }

  void desativarContausuario() {}
}
