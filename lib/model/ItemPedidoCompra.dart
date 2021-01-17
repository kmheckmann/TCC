import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/ItemPedido.dart';
import 'package:tcc_3/model/PedidoCompra.dart';

class ItemPedidoCompra extends ItemPedido{

  
  ItemPedidoCompra(PedidoCompra p) {
    pedido = p;
  }

//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  ItemPedidoCompra.buscarFirebase(DocumentSnapshot document) {
    id = document.documentID;
    labelListaProdutos = document.data()["label"];
    quantidade = document.data()["quantidade"];
    preco = document.data()["preco"];
  }
}