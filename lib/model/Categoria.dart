import 'package:cloud_firestore/cloud_firestore.dart';

class Categoria {
  String _id;
  String _descricao;
  bool _ativa;

  Categoria();

  bool get getAtiva {
    return _ativa;
  }

  set setAtiva(bool a) {
    _ativa = a;
  }

  String get getDescricao {
    return _descricao;
  }

  set setDescricao(String s) {
    _descricao = s;
  }

  String get getID {
    return _id;
  }

  set setID(String id) {
    _id = id;
  }

//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  Categoria.buscarFirebase(DocumentSnapshot snapshot) {
    setID = snapshot.id;
    setDescricao = snapshot.data()["descricao"];
    setAtiva = snapshot.data()["ativa"];
  }
}
