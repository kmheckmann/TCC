import 'package:cloud_firestore/cloud_firestore.dart';

class Categoria {
  String id;
  String descricao;
  bool ativa;

  Categoria();

//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  Categoria.buscarFirebase(DocumentSnapshot snapshot) {
    id = snapshot.id;
    descricao = snapshot.data()["descricao"];
    ativa = snapshot.data()["ativa"];
  }
}
