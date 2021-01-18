import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/PedidoVenda.dart';

class RelatorioPedidosBonificacaoController {
  List<PedidoVenda> pedidos = List<PedidoVenda>();
  Timestamp dataPedidoTimeStamp;
  DateTime dataPedido;
  PedidoVenda pedido;
  List<List<String>> lista = List<List<String>>();

  Future<List<PedidoVenda>> obterPedidosBonificacao(
      DateTime data1, DateTime data2) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('pedidos');
    QuerySnapshot obterPedidos =
        await ref.where("ehPedidoVenda", isEqualTo: true).get();

    obterPedidos.docs.forEach((document) {
      if (document.data()["tipoPedido"] == "Bonificação") {
        dataPedidoTimeStamp = document.data()["dataPedido"];
        dataPedido = dataPedidoTimeStamp.toDate();

        if (dataPedido.isAfter(data1) && dataPedido.isBefore(data2)) {
          pedido = PedidoVenda.buscarFirebase(document);
          pedidos.add(pedido);
        }
      }
    });

    print(pedidos.length);

    return Future.value(pedidos);
  }

  void criarListaTabelaList(List<PedidoVenda> pedidos) {
    pedidos.forEach((pedido) {
      lista.add([
        pedido.id.toString(),
        pedido.labelTelaPedidos,
        pedido.valorComDesconto.toString()
      ]);
    });
  }
}
