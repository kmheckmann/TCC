import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/model/Empresa.dart';
import 'package:cpfcnpj/cpfcnpj.dart';

class EmpresaController {
  EmpresaController();
  Empresa _empresa = Empresa();
  bool _existeCadastroCNPJ = true;
  bool _existeCadastroIE = true;
  bool _existeCadastroRazaoSocial = true;
  Empresa _emp;
  String _idCidadeEmpresa;

  String get getCidadeEmpresa {
    return _idCidadeEmpresa;
  }

  set setCidadeEmpresa(String cidadeEmpresa) {
    _idCidadeEmpresa = cidadeEmpresa;
  }

  Empresa get getEmpresa {
    return _empresa;
  }

  set setEmpresa(Empresa empresa) {
    _empresa = empresa;
  }

  Empresa get getEmp {
    return _emp;
  }

  set setEmp(Empresa emp) {
    _emp = emp;
  }

  bool get getExisteCadastroIE {
    return _existeCadastroIE;
  }

  set setExisteCadastroIE(bool existeCadastroIE) {
    _existeCadastroIE = existeCadastroIE;
  }

  bool get getExisteCadastroRazaoSocial {
    return _existeCadastroRazaoSocial;
  }

  set setExisteCadastroRazaoSocial(bool existeCadastroRazaoSocial) {
    _existeCadastroRazaoSocial = existeCadastroRazaoSocial;
  }

  bool get getExisteCadastroCNPJ {
    return _existeCadastroCNPJ;
  }

  set setExisteCadastroCNPJ(bool existeCadastroCNPJ) {
    _existeCadastroCNPJ = existeCadastroCNPJ;
  }

  Map<String, dynamic> dadosEmpresa = Map();
  Map<String, dynamic> dadosCidade = Map();

  Map<String, dynamic> converterParaMapa(Empresa e) {
    return {
      "razaoSocial": e.getRazaoSocial,
      "nomeFantasia": e.getNomeFantasia,
      "cnpj": e.getCnpj,
      "inscEstadual": e.getInscEstadual,
      "cep": e.getCep,
      "bairro": e.getBairro,
      "logradouro": e.getLogradouro,
      "numero": e.getNumero,
      "telefone": e.getTelefone,
      "email": e.getEmail,
      "ativo": e.getAtivo,
      "ehFornecedor": e.getEhFornecedor
    };
  }

  Future<Null> persistirEmpresa(Map<String, dynamic> dadosEmpresa,
      Map<String, dynamic> dadosCidade) async {
    this.dadosEmpresa = dadosEmpresa;
    this.dadosCidade = dadosCidade;
    await FirebaseFirestore.instance
        .collection("empresas")
        .doc(dadosEmpresa["cnpj"])
        .set(dadosEmpresa);

    await FirebaseFirestore.instance
        .collection("empresas")
        .doc(dadosEmpresa["cnpj"])
        .collection("cidade")
        .doc("IDcidade")
        .set(dadosCidade);
  }

  //Método para buscar os valores da cidade na subcoleção dentro da empresa
  Future<Null> obterIDCidadeEmpresa(String idEmpresa) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("empresas")
        .doc(idEmpresa)
        .collection("cidade")
        .doc("IDcidade")
        .get();

    _idCidadeEmpresa = doc.data()["id"];
  }

  Future verificarExistenciaCNPJ(String cnpj, VoidCallback terminou) async {
    await FirebaseFirestore.instance
        .collection("empresas")
        .doc(cnpj)
        .get()
        .then((doc) {
      if (!doc.exists) {
        _existeCadastroCNPJ = false;
      }
      terminou();
    });
  }

  Future verificarExistenciaInscEstadual(
      String ie, VoidCallback terminou) async {
    await FirebaseFirestore.instance
        .collection("empresas")
        .where("inscEstadual", isEqualTo: ie)
        .get()
        .then((query) {
      if (query.docs.length == 0 || query == null) {
        _existeCadastroIE = false;
      }
      terminou();
    });
  }

  Future verificarExistenciaRazaoSocial(
      String razaoSocial, VoidCallback terminou) async {
    CollectionReference ref = FirebaseFirestore.instance.collection("empresas");
    //Obtem empresas com mesma razão social
    await ref
        .where("razaoSocial", isEqualTo: razaoSocial)
        .get()
        .then((eventsQuery) {
      if (eventsQuery.docs.length == 0 || eventsQuery == null) {
        _existeCadastroRazaoSocial = false;
      }
      terminou();
    });
  }

  //Método utilizado pela tela te pedidos
  //seleciona-se a empresa no comboBox e pelo nome fantasia busca os outros dados da empresa
  Future<Empresa> obterEmpresaPorDescricao(String nomeEmpresa) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('empresas');
    QuerySnapshot eventsQuery =
        await ref.where("razaoSocial", isEqualTo: nomeEmpresa).get();

    eventsQuery.docs.forEach((document) {
      _emp = Empresa.buscarFirebase(document);
      _emp.setId = document.id;
    });
    return Future.value(_emp);
  }

  bool validarCNPJ(String cnpj) {
    bool cnpjValido;
    CNPJ.format(cnpj);
    if (CNPJ.isValid(cnpj)) {
      cnpjValido = true;
    } else {
      cnpjValido = false;
    }
    return cnpjValido;
  }
}
