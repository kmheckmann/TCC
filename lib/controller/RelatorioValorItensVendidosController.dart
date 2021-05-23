import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/ItemPedidoVenda.dart';
import 'package:tcc_3/model/PedidoVenda.dart';
import 'package:tcc_3/model/Produto.dart';

class RelatorioValorItensVendidosController {
  List<PedidoVenda> pedidos = List<PedidoVenda>();
  List<ItemPedidoVenda> itensPedidoVenda = List<ItemPedidoVenda>();
  HashMap itensPedidoVendaAux = new HashMap<String, double>();
  Timestamp dataPedidoTimeStamp;
  List<List<String>> lista = List<List<String>>();
  DateTime dataPedido;
  PedidoVenda pedido;
  ItemPedidoVenda itemPedidoVenda;
  Produto prod = Produto();

  Future<List<PedidoVenda>> obterPedidosRelatorio(
      DateTime data1, DateTime data2) async {
    //Esse método busca os pedidos de venda para o cliente selecionado no filtro
    pedidos.clear();
    CollectionReference ref = FirebaseFirestore.instance.collection('pedidos');
    QuerySnapshot obterPedidos =
        await ref.where("ehPedidoVenda", isEqualTo: true).get();

    obterPedidos.docs.forEach((document) {
      dataPedidoTimeStamp = document.data()["dataPedido"];
      dataPedido = dataPedidoTimeStamp.toDate();

      if (document.data()["tipoPedido"] == "Normal") {
        if (dataPedido.isAfter(data1) && dataPedido.isBefore(data2)) {
          pedido = PedidoVenda.buscarFirebase(document);
          pedidos.add(pedido);
        }
      }
    });

    return Future.value(pedidos);
  }

  Future<List<ItemPedidoVenda>> itensRelatorio(List<PedidoVenda> p) {
    p.forEach((pedido) async {
      CollectionReference ref = FirebaseFirestore.instance
          .collection('pedidos')
          .doc(pedido.getID)
          .collection('itens');
      QuerySnapshot obterItens = await ref.get();

      obterItens.docs.forEach((document) {
        itemPedidoVenda = ItemPedidoVenda.buscarFirebase(document);
        itensPedidoVenda.add(itemPedidoVenda);
      });
    });
    return Future.value(itensPedidoVenda);
  }

  void removerDuplicados(List<ItemPedidoVenda> lista) {
    lista.forEach((element) {
      if (itensPedidoVendaAux.containsKey(
          element.produto.getID + ' - ' + element.labelListaProdutos)) {
        String key = element.produto.getID + ' - ' + element.labelListaProdutos;
        double novoPreco =
            itensPedidoVendaAux[key] += (element.preco * element.quantidade);
        itensPedidoVendaAux[key] = novoPreco;
      } else {
        itensPedidoVendaAux[element.produto.getID +
            ' - ' +
            element.labelListaProdutos] = element.preco * element.quantidade;
      }
    });
  }

  void criarListaTabelaList(HashMap<String, double> itens) {
    itens.forEach((key, value) {
      lista.add([key, value.toString()]);
    });
  }
}
