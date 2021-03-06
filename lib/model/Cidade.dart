import 'package:cloud_firestore/cloud_firestore.dart';

class Cidade {
  //ID do documento no firebase
  String _id;

  String _nome;
  String _estado;
  bool _ativa;

  Cidade();

  bool get getAtiva {
    return _ativa;
  }

  set setAtiva(bool a) {
    _ativa = a;
  }

  String get getID {
    return _id;
  }

  set setID(String id) {
    _id = id;
  }

  String get getNome {
    return _nome;
  }

  set setNome(String nome) {
    _nome = nome;
  }

  String get getEstado {
    return _estado;
  }

  set setEstado(String e) {
    _estado = e;
  }


//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  Cidade.buscarFirebase(DocumentSnapshot snapshot) {
    setID = snapshot.id;
    setNome = snapshot.data()["nome"];
    setEstado = snapshot.data()["estado"];
    setAtiva = snapshot.data()["ativa"];
  }
}
