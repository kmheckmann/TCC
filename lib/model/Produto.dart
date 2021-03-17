import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Categoria.dart';

class Produto {
  //ID do documento no firebase
  String _id;
  int _codBarra;
  String _descricao;
  double _percentualLucro;
  bool _ativo;
  Categoria _categoria = Categoria();

  Produto();

  String get getID {
    return _id;
  }

  set setID(String id) {
    _id = id;
  }

  Categoria get getCategoria {
    return _categoria;
  }

  set setCategoria(Categoria cat) {
    _categoria = cat;
  }

  int get getCodBarra {
    return _codBarra;
  }

  set setCodBarra(int codBarra) {
    _codBarra = codBarra;
  }

  String get getDescricao {
    return _descricao;
  }

  set setDescricao(String desc) {
    _descricao = desc;
  }

  double get getPercentLucro {
    return _percentualLucro;
  }

  set setPercentLucro(double percent) {
    _percentualLucro = percent;
  }

  bool get getAtivo {
    return _ativo;
  }

  set setAtivo(bool a) {
    _ativo = a;
  }

//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  Produto.buscarFirebase(DocumentSnapshot snapshot) {
    setID = snapshot.id;
    setDescricao = snapshot.data()["descricao"];
    setCodBarra = snapshot.data()["codBarra"];
    setPercentLucro = snapshot.data()["percentLucro"];
    setAtivo = snapshot.data()["ativo"];
  }
}
