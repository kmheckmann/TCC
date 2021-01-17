import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Empresa.dart';
import 'package:tcc_3/model/ItemPedidoVenda.dart';
import 'package:tcc_3/model/PedidoVenda.dart';
import 'package:sortedmap/sortedmap.dart';
import 'package:tcc_3/model/Produto.dart';

class RelatorioItensClienteController {
  List<PedidoVenda> pedidos = List<PedidoVenda>();
  List<ItemPedidoVenda> itensPedidoVenda = List<ItemPedidoVenda>();
  HashMap itensPedidoVendaAux = new HashMap<String, int>();
  Timestamp dataPedidoTimeStamp;
  List<List<String>> lista = List<List<String>>();
  DateTime dataPedido;
  PedidoVenda pedido;
  ItemPedidoVenda itemPedidoVenda;
  Produto prod = Produto();

  Future<Null> obterPedidosRelatorio(
      Empresa c, DateTime data1, DateTime data2) async {
    //Esse método busca os pedidos que se encaixam no filtro do relatorio
    //Itens vendidos num determinado periodo para um cliente
    pedidos.clear();
    CollectionReference ref = FirebaseFirestore.instance.collection('pedidos');
    QuerySnapshot obterPedidos =
        await ref.where("label", isEqualTo: c.razaoSocial).get();

    obterPedidos.docs.forEach((document) {
      if (document.data()["ehPedidoVenda"] == true) {
        dataPedidoTimeStamp = document.data()["dataPedido"];
        dataPedido = dataPedidoTimeStamp.toDate();

        if (dataPedido.isAfter(data1) && dataPedido.isBefore(data2)) {
          pedido = PedidoVenda.buscarFirebase(document);
          pedidos.add(pedido);
        }
      }
    });
  }

  Future<List<ItemPedidoVenda>> itensRelatorio(List<PedidoVenda> p) {
    p.forEach((pedido) async {
      CollectionReference ref = FirebaseFirestore.instance
          .collection('pedidos')
          .doc(pedido.id)
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
          element.produto.id + ' - ' + element.labelListaProdutos)) {
        String key = element.produto.id + ' - ' + element.labelListaProdutos;
        int novaQtde = itensPedidoVendaAux[key] += element.quantidade;
        itensPedidoVendaAux[key] = novaQtde;
      } else {
        itensPedidoVendaAux[element.produto.id +
            ' - ' +
            element.labelListaProdutos] = element.quantidade;
      }
    });
  }

  void criarListaTabelaList(HashMap<String, int> itens) {
    itens.forEach((key, value) {
      lista.add([key, value.toString()]);
    });
  }
}
