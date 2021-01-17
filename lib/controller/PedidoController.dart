import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Empresa.dart';
import 'package:tcc_3/model/ItemPedido.dart';
import 'package:tcc_3/model/Pedido.dart';
import 'package:tcc_3/model/Usuario.dart';

abstract class PedidoController {
  Empresa empresa = Empresa();
  Usuario usuario = Usuario();
  bool podeFinalizar = false;
  String proxID;
  Map<String, dynamic> dadosPedido = Map();
  Map<String, dynamic> dadosUsuario = Map();
  Map<String, dynamic> dadosEmpresa = Map();

  Future<Null> obterProxID() async {
    int idTemp = 0;
    int docID;
    CollectionReference ref = Firestore.instance.collection("pedidos");
    QuerySnapshot eventsQuery = await ref.getDocuments();

    eventsQuery.documents.forEach((document) {
      docID = int.parse(document.documentID);
      if (eventsQuery.documents.length == 0) {
        idTemp = 1;
        proxID = idTemp.toString();
      } else {
        if (docID > idTemp) {
          idTemp = docID;
        }
      }
    });

    idTemp = idTemp + 1;
    proxID = idTemp.toString();
  }

  Map<String, dynamic> converterParaMapa(Pedido p) {
    return {
      "valorTotal": p.valorTotal,
      "percentualDesconto": p.percentualDesconto,
      "tipoPagamento": p.tipoPagamento,
      "ehPedidoVenda": p.ehPedidoVenda,
      "dataPedido": p.dataPedido,
      "pedidoFinalizado": p.pedidoFinalizado,
      "label": p.labelTelaPedidos,
      "valorComDesconto": p.valorComDesconto,
      "dataFinalPedido": p.dataFinalPedido,
    };
  }

  Future<Null> persistirAlteracoesPedido(
      Map<String, dynamic> dadosPedido,
      Map<String, dynamic> dadosEmpresa,
      Map<String, dynamic> dadosUsuario,
      String idPedido);

//Busca os dados da empresa vinculada ao pedido
  Future<Null> obterEmpresadoPedido(String idPedido) async {
    Empresa e = Empresa();
    //Acessa a collection em que a empresa está
    CollectionReference ref = Firestore.instance
        .collection('pedidos')
        .document(idPedido)
        .collection('cliente');
//Obtem a empresa
    QuerySnapshot obterEmpresaPedido = await ref.getDocuments();

//Acessa a collection de todas as empresas cadastradas e pega todas as empresas
    CollectionReference refCliente = Firestore.instance.collection('empresas');
    QuerySnapshot obterDadosEmpresa = await refCliente.getDocuments();

//Compara o ID da empresa vinculada ao pedido com as existentes até encontrar o correspondente
//Após isso busca as outras informações além do ID
    obterEmpresaPedido.documents.forEach((document) {
      e.id = document.data()["id"];

      obterDadosEmpresa.documents.forEach((document1) {
        if (e.id == document1.documentID) {
          e = Empresa.buscarFirebase(document1);
        }
      });
    });
    empresa = e;
  }

//Método para obter as informações do vendedor do pedido
  Future<Null> obterUsuariodoPedido(String idPedido) async {
    Usuario user = Usuario();
    //Obtem o ID do vendedor do pedido
    CollectionReference ref = Firestore.instance
        .collection('pedidos')
        .document(idPedido)
        .collection('vendedor');
    QuerySnapshot obterUsuario = await ref.getDocuments();

//Obtem todos os usuarios cadastrados
    CollectionReference refCliente = Firestore.instance.collection('usuarios');
    QuerySnapshot obterDadosUsuario = await refCliente.getDocuments();

//Compara o ID do vendedor do pedido com todos os cadastrados até encontrar um igual
//Após isso obtém as demais informações do vendedor
    obterUsuario.documents.forEach((document) {
      user.setID = document.data()["id"];

      obterDadosUsuario.documents.forEach((document1) {
        if (user.getID == document1.documentID) {
          user = Usuario.buscarFirebase(document1);
        }
      });
    });
    usuario = user;
  }

//Aplica no valor total do pedido o desconto informado
  void calcularDesconto(Pedido p);

//Método chamado para atualizar regularmente o valor total do pedido
  void somarPrecoNoVlTotal(Pedido p, ItemPedido novoItem);

//Método utilizado quando é realizada uma alteração num item do pedido
  void atualizarPrecoNoVlTotal(double precoAntigo, Pedido p, ItemPedido item) {
    //Diminui o valor total antigo obtido com a soma das quantidade do item
    double vlTotalItemAntigo = precoAntigo * item.quantidade;
    p.valorTotal -= vlTotalItemAntigo;
    //Após diminuir, chama o método abaixo para somar o novo valor no pedido
    somarPrecoNoVlTotal(p, item);
  }

//Método utilizado quando um item é removido, para diminuir seu valor do valor total do pedido
  void subtrairPrecoVlTotal(Pedido p, ItemPedido itemExcluido);

//Método chamado ao utilizar o botão de atualizar na capa do pedido
  Future<Null> atualizarCapaPedido(String idPedido);

  Future<Null> verificarSePedidoTemItens(Pedido p) async {
    //este método tem o objetivo de verificar se o pedido possui itens cadastrados
    //para poder finalizar o pedido

    //Acessa a coleção onde os iens ficam salvos
    CollectionReference ref = Firestore.instance
        .collection("pedidos")
        .document(p.id)
        .collection("itens");
    //Obtém todos os documentos da coleção
    QuerySnapshot _obterItens = await ref.getDocuments();

    if (_obterItens.documents.length > 0) {
      podeFinalizar = true;
    } else {
      podeFinalizar = false;
    }
  }
}
