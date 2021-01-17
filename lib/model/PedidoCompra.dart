import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Pedido.dart';

class PedidoCompra extends Pedido {
  PedidoCompra();

//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  PedidoCompra.buscarFirebase(DocumentSnapshot snapshot) {
    id = snapshot.documentID;
    valorTotal = snapshot.data()["valorTotal"];
    percentualDesconto = snapshot.data()["percentualDesconto"];
    tipoPagamento = snapshot.data()["tipoPagamento"];
    ehPedidoVenda = snapshot.data()["ehPedidoVenda"];
    dataPedido = snapshot.data()["dataPedido"].toDate();
    pedidoFinalizado = snapshot.data()["pedidoFinalizado"];
    labelTelaPedidos = snapshot.data()["label"];
    valorComDesconto = snapshot.data()["valorComDesconto"];
    dataFinalPedido = snapshot.data()["dataFinalPedido"].toDate();
  }
}
