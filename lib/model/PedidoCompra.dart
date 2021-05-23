import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Pedido.dart';

class PedidoCompra extends Pedido {
  PedidoCompra();
  Timestamp _dataPedidoTimeStamp;
  Timestamp _dataFinalPedidoTimeStamp;

//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  PedidoCompra.buscarFirebase(DocumentSnapshot snapshot) {
    setID = snapshot.id;
    setValorTotal = snapshot.data()["valorTotal"];
    setPercentDesconto = snapshot.data()["percentualDesconto"];
    setTipoPgto = snapshot.data()["tipoPagamento"];
    setEhPedidoVenda = snapshot.data()["ehPedidoVenda"];
    _dataPedidoTimeStamp = snapshot.data()["dataPedido"];
    setPedidoFinalizado = snapshot.data()["pedidoFinalizado"];
    setLabel = snapshot.data()["label"];
    setValorDesconto = snapshot.data()["valorComDesconto"];
    _dataFinalPedidoTimeStamp = snapshot.data()["dataFinalPedido"];
    setDataPedido = _dataPedidoTimeStamp.toDate();
    if (_dataFinalPedidoTimeStamp != null)
      setDataFinal = _dataFinalPedidoTimeStamp.toDate();
  }
}
