import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';

class Usuario extends Model {
  //ID do documento no firebase
  String _id;
  String _nome;
  String _cpf;
  String _email;
  String _senha;
  bool _ehAdministrador;
  bool _ativo;
  bool _primeiroLogin;
  bool _bloqueado;

  Usuario();

  bool get getEhAdm {
    return _ehAdministrador;
  }

  set setEhAdm(bool ehadm) {
    _ehAdministrador = ehadm;
  }

  bool get getPrimeiroLogin{
    return _primeiroLogin;
  }

  set setPrimeiroLogin(bool primeiroLogin) {
    _primeiroLogin = primeiroLogin;
  }


  String get getSenha {
    return _senha;
  }

  set setSenha(String senha) {
    _senha = senha;
  }

  String get getEmail {
    return _email;
  }

  set setEmail(String email) {
    _email = email;
  }

  String get getCPF {
    return _cpf;
  }

  set setCPF(String cpf) {
    _cpf = cpf;
  }

  String get getNome {
    return _nome;
  }

  set setNome(String nome) {
    _nome = nome;
  }

  String get getID {
    return _id;
  }

  set setID(String id) {
    _id = id;
  }

  bool get getAtivo {
    return _ativo;
  }

  set setAtivo(bool a) {
    _ativo = a;
  }

  bool get getBloqueado {
    return _bloqueado;
  }

  set setBloqueado(bool b) {
    _bloqueado = b;
  }

//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  Usuario.buscarFirebase(DocumentSnapshot snapshot) {
    setID = snapshot.id;
    setNome = snapshot.data()["nome"];
    setCPF = snapshot.data()["cpf"]; 
    setEmail = snapshot.data()["email"];
    setEhAdm = snapshot.data()["ehAdm"];
    setAtivo = snapshot.data()["ativo"];
    setPrimeiroLogin = snapshot.data()["primeiroLogin"];
    setBloqueado = snapshot.data()["bloqueado"];
  }
}
