import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Pedido.dart';

class PedidoVenda extends Pedido {
  String tipoPedido;

  Timestamp dataPedidoTimeStamp;
  Timestamp dataFinalPedidoTimeStamp;

  PedidoVenda();

  PedidoVenda.buscarFirebase(DocumentSnapshot snapshot) {
    setID = snapshot.id;
    setValorTotal = snapshot.data()["valorTotal"];
    setPercentDesconto = snapshot.data()["percentualDesconto"];
    setTipoPgto = snapshot.data()["tipoPagamento"];
    tipoPedido = snapshot.data()["tipoPedido"];
    setEhPedidoVenda = snapshot.data()["ehPedidoVenda"];
    dataPedidoTimeStamp = snapshot.data()["dataPedido"];
    setPedidoFinalizado = snapshot.data()["pedidoFinalizado"];
    setLabel = snapshot.data()["label"];
    setValorDesconto = snapshot.data()["valorComDesconto"];
    dataFinalPedidoTimeStamp = snapshot.data()["dataFinalPedido"];
    setDataPedido = dataPedidoTimeStamp.toDate();
    if (dataFinalPedidoTimeStamp != null)
      setDataFinal = dataFinalPedidoTimeStamp.toDate();
  }
}
