import 'package:tcc_3/model/Usuario.dart';
import 'package:tcc_3/model/Empresa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Rota {
  //ID do documento no firebase
  String _idFirebase;

  Usuario _vendedor = Usuario();
  Empresa _cliente = Empresa();
  String _diaSemana;
  String _frequencia;
  String _tituloRota;
  String _idv;
  bool _ativa;

  Rota();

  String get getIdFirebase{
    return _idFirebase;
  }

  set setIdFirebase(String id){
    _idFirebase = id;
  }

  Usuario get getVendedor{
    return _vendedor;
  }

  set setVendedor(Usuario v){
    _vendedor = v;
  }

  Empresa get getCliente{
    return _cliente;
  }

  set setCliente(Empresa e){
    _cliente = e;
  }

  String get getDiaSemana{
    return _diaSemana;
  }

  set setDiaSemana(String d){
    _diaSemana = d;
  }

  String get getFrequencia{
    return _frequencia;
  }

  set setFrequencia(String f){
    _frequencia = f;
  }

  String get getTituloRota{
    return _tituloRota;
  }

  set setTituloRota(String t){
    _tituloRota = t;
  }

  String get getIDV{
    return _idv;
  }

  set setIDV(String idv){
    _idv = idv;
  }

  bool get getAtiva{
    return _ativa;
  }

  set setAtiva(bool a){
    _ativa = a;
  }

//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  Rota.buscarFirebase(DocumentSnapshot snapshot) {
    _idFirebase = snapshot.documentID;
    _frequencia = snapshot.data()["frequencia"];
    _diaSemana = snapshot.data()["diaSemana"];
    _ativa = snapshot.data()["ativa"];
    _tituloRota = snapshot.data()["tituloRota"];
    _idv = snapshot.data()["idv"];
  }
}
