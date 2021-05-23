import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:tcc_3/model/Empresa.dart';
import 'package:tcc_3/model/ItemPedido.dart';
import 'package:tcc_3/model/Pedido.dart';
import 'package:tcc_3/model/Usuario.dart';

abstract class PedidoController {
  Empresa _empresa = Empresa();
  Usuario _usuario = Usuario();
  bool _podeFinalizar = false;
  Map<String, dynamic> _dadosPedido = Map();
  Map<String, dynamic> _dadosUsuario = Map();
  Map<String, dynamic> _dadosEmpresa = Map();
  String _idEmpresa;
  String _idUser;

  Empresa get getEmpresa {
    return _empresa;
  }

  set setEmpresa(Empresa emp) {
    _empresa = emp;
  }

  Usuario get getUser {
    return _usuario;
  }

  set setUser(Usuario user) {
    _usuario = user;
  }

  bool get getPodeFinalizar {
    return _podeFinalizar;
  }

  set setPodeFinalizar(bool podeFinalizar) {
    _podeFinalizar = podeFinalizar;
  }

  Map<String, dynamic> get getDadosPedido {
    return _dadosPedido;
  }

  set setDadosPedido(Map<String, dynamic> dadosPedido) {
    _dadosPedido = dadosPedido;
  }

  Map<String, dynamic> get getDadosUser {
    return _dadosUsuario;
  }

  set setDadosUser(Map<String, dynamic> dadosUser) {
    _dadosUsuario = dadosUser;
  }

  Map<String, dynamic> get getDadosEmpresa {
    return _dadosEmpresa;
  }

  set setDadosEmpresa(Map<String, dynamic> dadosEmp) {
    _dadosEmpresa = dadosEmp;
  }

  String get getIDUser {
    return _idUser;
  }

  set setIDUser(String idUser) {
    _idUser = idUser;
  }

  String get getIDEmpresa {
    return _idEmpresa;
  }

  set setIDEmpresa(String idEmpresa) {
    _idEmpresa = idEmpresa;
  }

  Map<String, dynamic> converterParaMapa(Pedido p) {
    return {
      "valorTotal": p.getValorTotal,
      "percentualDesconto": p.getPercentDesconto,
      "tipoPagamento": p.getTipoPgto,
      "ehPedidoVenda": p.getEhPedidoVenda,
      "dataPedido": p.getDataPedido,
      "pedidoFinalizado": p.getPedidoFinalizado,
      "label": p.getLabel,
      "valorComDesconto": p.getValorDesconto,
      "dataFinalPedido": p.getDataFinal,
    };
  }

  Future<Null> persistirAlteracoesPedido(
      Map<String, dynamic> dadosPedido,
      Map<String, dynamic> dadosEmpresa,
      Map<String, dynamic> dadosUsuario,
      String idPedido);

//Busca os dados da empresa vinculada ao pedido
  Future obterIDEmpresaPedido(String idPedido) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("pedidos")
        .doc(idPedido)
        .collection("cliente")
        .doc("IDcliente")
        .get();
    setIDEmpresa = doc.data()["id"];
  }

//Método para obter as informações do vendedor do pedido
  Future<Null> obterUsuariodoPedido(String idPedido) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("pedidos")
        .doc(idPedido)
        .collection("vendedor")
        .doc("IDvendedor")
        .get();
    _idUser = doc.data()["id"];
  }

  //Aplica no valor total do pedido o desconto informado
  void calcularDesconto(Pedido p);

  //Método chamado para atualizar regularmente o valor total do pedido
  void somarPrecoNoVlTotal(Pedido p, ItemPedido novoItem);

  //Método utilizado quando é realizada uma alteração num item do pedido
  void atualizarPrecoNoVlTotal(double precoAntigo, Pedido p, ItemPedido item) {
    //Diminui o valor total antigo obtido com a soma das quantidade do item
    double vlTotalItemAntigo = precoAntigo * item.quantidade;
    p.setValorTotal = p.getValorTotal - vlTotalItemAntigo;
    //Após diminuir, chama o método abaixo para somar o novo valor no pedido
    somarPrecoNoVlTotal(p, item);
  }

  //Método utilizado quando um item é removido, para diminuir seu valor do valor total do pedido
  void subtrairPrecoVlTotal(Pedido p, ItemPedido itemExcluido);

  //Método chamado ao utilizar o botão de atualizar na capa do pedido
  Future atualizarCapaPedido(String idPedido, VoidCallback terminou);

  Future verificarSePedidoTemItens(Pedido p) async {
    //este método tem o objetivo de verificar se o pedido possui itens cadastrados
    //para poder finalizar o pedido

    //Acessa a coleção onde os iens ficam salvos
    CollectionReference ref = FirebaseFirestore.instance
        .collection("pedidos")
        .doc(p.getID)
        .collection("itens");
    //Obtém todos os documentos da coleção
    QuerySnapshot _obterItens = await ref.get();

    if (_obterItens.docs.length > 0) {
      _podeFinalizar = true;
    } else {
      _podeFinalizar = false;
    }
  }
}
