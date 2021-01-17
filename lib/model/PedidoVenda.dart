import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Pedido.dart';

class PedidoVenda extends Pedido {
  String tipoPedido;

  Timestamp dataPedidoTimeStamp;
  Timestamp dataFinalPedidoTimeStamp;

  PedidoVenda();

  PedidoVenda.buscarFirebase(DocumentSnapshot snapshot) {
    id = snapshot.id;
    valorTotal = snapshot.data()["valorTotal"];
    percentualDesconto = snapshot.data()["percentualDesconto"];
    tipoPagamento = snapshot.data()["tipoPagamento"];
    tipoPedido = snapshot.data()["tipoPedido"];
    ehPedidoVenda = snapshot.data()["ehPedidoVenda"];
    dataPedidoTimeStamp = snapshot.data()["dataPedido"];
    pedidoFinalizado = snapshot.data()["pedidoFinalizado"];
    labelTelaPedidos = snapshot.data()["label"];
    valorComDesconto = snapshot.data()["valorComDesconto"];
    dataFinalPedidoTimeStamp = snapshot.data()["dataFinalPedido"];
    dataPedido = dataPedidoTimeStamp.toDate();
    if (dataFinalPedidoTimeStamp != null)
      dataFinalPedido = dataFinalPedidoTimeStamp.toDate();

      print(dataPedido);
  }

  @override
  Map<String, dynamic> converterParaMapa() {
    return {
      "valorTotal": valorTotal + 0.0,
      "percentualDesconto": percentualDesconto + 0.0,
      "tipoPagamento": tipoPagamento,
      "ehPedidoVenda": ehPedidoVenda,
      "tipoPedido": tipoPedido,
      "dataPedido": dataPedido,
      "pedidoFinalizado": pedidoFinalizado,
      "dataFinalPedido": dataFinalPedido,
      "label": labelTelaPedidos,
      "valorComDesconto": valorComDesconto
    };
  }
}
