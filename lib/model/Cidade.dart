import 'package:cloud_firestore/cloud_firestore.dart';

class Cidade {
  //ID do documento no firebase
  String id;

  String nome;
  String estado;
  bool ativa;

  Cidade();

//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  Cidade.buscarFirebase(DocumentSnapshot snapshot) {
    id = snapshot.id;
    nome = snapshot.data()["nome"];
    estado = snapshot.data()["estado"];
    ativa = snapshot.data()["ativa"];
  }
}
