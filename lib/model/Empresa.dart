import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Cidade.dart';

class Empresa {
  //ID do documento no firebase
  String id;
  String razaoSocial;
  String nomeFantasia;
  String cnpj;
  String inscEstadual;
  String cep;
  Cidade cidade = Cidade();
  String bairro;
  String logradouro;
  int numero;
  String telefone;
  String email;
  bool ativo;
  bool ehFornecedor;

  Empresa();

//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  Empresa.buscarFirebase(DocumentSnapshot snapshot) {
    
      id = snapshot.id;
      razaoSocial = snapshot.data()['razaoSocial'];
      nomeFantasia = snapshot.data()['nomeFantasia'];
      cnpj = snapshot.data()['cnpj'];
      inscEstadual = snapshot.data()['inscEstadual'];
      cep = snapshot.data()['cep'];
      bairro = snapshot.data()['bairro'];
      logradouro = snapshot.data()['logradouro'];
      numero = snapshot.data()['numero'];
      telefone = snapshot.data()['telefone'];
      email = snapshot.data()['email'];
      ehFornecedor = snapshot.data()['ehFornecedor'];
      ativo = snapshot.data()['ativo'];
    
  }
}
