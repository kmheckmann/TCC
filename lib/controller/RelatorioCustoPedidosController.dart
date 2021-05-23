import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/PedidoVenda.dart';

class RelatorioCustoPedidosController {
  Timestamp dataPedidoTimeStamp;
  DateTime dataPedido;
  PedidoVenda pedido;
  List<List<String>> lista = List<List<String>>();

  Future<Null> obterPedidosBonificacao(
      DateTime data1, DateTime data2, String tipoPedido) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('pedidos');
    QuerySnapshot obterPedidos =
        await ref.where("tipoPedido", isEqualTo: tipoPedido).get();

    obterPedidos.docs.forEach((document) {
      dataPedidoTimeStamp = document.data()["dataPedido"];
      dataPedido = dataPedidoTimeStamp.toDate();

      if (dataPedido.isAfter(data1) && dataPedido.isBefore(data2)) {
        pedido = PedidoVenda.buscarFirebase(document);
        lista.add([
          pedido.getID.toString(),
          pedido.getLabel,
          pedido.getValorDesconto.toString()
        ]);
      }
    });

    print(lista.length);
  }

  void ordenar() {
    lista.sort();
  }
}
