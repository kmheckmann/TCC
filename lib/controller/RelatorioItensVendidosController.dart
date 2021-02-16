import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/ItemPedidoVenda.dart';
import 'package:tcc_3/model/PedidoVenda.dart';
import 'package:tcc_3/model/Produto.dart';

class RelatorioItensVendidosController {
  List<PedidoVenda> pedidos = List<PedidoVenda>();
  List<ItemPedidoVenda> itensPedidoVenda = List<ItemPedidoVenda>();
  HashMap itensPedidoVendaAux = new HashMap<String, int>();
  LinkedHashMap itensOrdenados;
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

      if (dataPedido.isAfter(data1) && dataPedido.isBefore(data2)) {
        pedido = PedidoVenda.buscarFirebase(document);
        pedidos.add(pedido);
      }
    });

    return Future.value(pedidos);
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

  void _ordenarMap(HashMap<String, int> itens) {
    var sortedkeys = itens.keys.toList()..sort((k1,k2,) => itens[k2].compareTo(itens[k1]));
    itensOrdenados = new LinkedHashMap.fromIterable(sortedkeys,
        key: (k) => k, value: (k) => itens[k]);
  }

  void removerDuplicados(List<ItemPedidoVenda> lista) {
    print(itensPedidoVendaAux);
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

  void criarListaTabelaList() {
    _ordenarMap(itensPedidoVendaAux);
    itensOrdenados.forEach((key, value) {
      lista.add([key, value.toString()]);
    });
  }

  void limparLinkedHashMap(){
    if(itensOrdenados != null){
      itensOrdenados.clear();
    }
  }
}
