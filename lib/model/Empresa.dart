import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/controller/CidadeController.dart';
import 'package:tcc_3/model/Cidade.dart';

class Empresa {
  //ID do documento no firebase
  String _id;
  String _razaoSocial;
  String _nomeFantasia;
  String _cnpj;
  String _inscEstadual;
  String _cep;
  Cidade _cidade = Cidade();
  String _bairro;
  String _logradouro;
  int _numero;
  String _telefone;
  String _email;
  bool _ativo;
  bool _ehFornecedor;
  CidadeController _cidadeController = CidadeController();

  Empresa();

  set setId(String id) {
    _id = id;
  }

  String get getId {
    return _id;
  }

  set setRazaoSocial(String razaoSocial) {
    _razaoSocial = razaoSocial;
  }

  String get getRazaoSocial {
    return _razaoSocial;
  }

  set setNomeFantasia(String nomeFantasia) {
    _nomeFantasia = nomeFantasia;
  }

  String get getNomeFantasia {
    return _nomeFantasia;
  }

  set setCnpj(String cnpj) {
    _cnpj = cnpj;
  }

  String get getCnpj {
    return _cnpj;
  }

  set setInscEstadual(String inscEstadual) {
    _inscEstadual = inscEstadual;
  }

  String get getInscEstadual {
    return _inscEstadual;
  }

  set setCep(String cep) {
    _cep = cep;
  }

  String get getCep {
    return _cep;
  }

  set setCidade(Cidade cidade) {
    _cidade = cidade;
  }

  Cidade get getCidade {
    return _cidade;
  }

  set setBairro(String bairro) {
    _bairro = bairro;
  }

  String get getBairro {
    return _bairro;
  }

  set setLogradouro(String logradouro) {
    _logradouro = logradouro;
  }

  String get getLogradouro {
    return _logradouro;
  }

  set setNumero(int numero) {
    _numero = numero;
  }

  int get getNumero {
    return _numero;
  }

  set setTelefone(String tel) {
    _telefone = tel;
  }

  String get getTelefone {
    return _telefone;
  }

  set setEmail(String email) {
    _email = email;
  }

  String get getEmail {
    return _email;
  }

  bool get getAtivo {
    return _ativo;
  }

  set setAtivo(bool a) {
    _ativo = a;
  }

  bool get getEhFornecedor {
    return _ehFornecedor;
  }

  set setEhFornecedor(bool f) {
    _ehFornecedor = f;
  }

//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  Empresa.buscarFirebase(DocumentSnapshot snapshot) {
    _id = snapshot.id;
    _razaoSocial = snapshot.data()['razaoSocial'];
    _nomeFantasia = snapshot.data()['nomeFantasia'];
    _cnpj = snapshot.data()['cnpj'];
    _inscEstadual = snapshot.data()['inscEstadual'];
    _cep = snapshot.data()['cep'];
    _bairro = snapshot.data()['bairro'];
    _logradouro = snapshot.data()['logradouro'];
    _numero = snapshot.data()['numero'];
    _telefone = snapshot.data()['telefone'];
    _email = snapshot.data()['email'];
    _ehFornecedor = snapshot.data()['ehFornecedor'];
    _ativo = snapshot.data()['ativo'];
  }
}
