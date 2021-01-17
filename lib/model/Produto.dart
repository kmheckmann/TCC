import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Categoria.dart';

class Produto {
  //ID do documento no firebase
  String id;

  int codigo;
  int codBarra;
  String descricao;
  double percentualLucro;
  bool ativo;
  Categoria categoria = Categoria();

  Produto();

//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  Produto.buscarFirebase(DocumentSnapshot snapshot) {
    id = snapshot.documentID;
    descricao = snapshot.data()["descricao"];
    codigo = snapshot.data()["codigo"];
    codBarra = snapshot.data()["codBarra"];
    percentualLucro = snapshot.data()["percentLucro"];
    ativo = snapshot.data()["ativo"];
  }
}
