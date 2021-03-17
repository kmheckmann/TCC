import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/ItemPedido.dart';
import 'package:tcc_3/model/PedidoVenda.dart';
import 'package:tcc_3/model/Produto.dart';

class ItemPedidoVenda extends ItemPedido {
  ItemPedidoVenda(PedidoVenda p) {
    pedido = p;
  }

//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  ItemPedidoVenda.buscarFirebase(DocumentSnapshot document) {
    id = document.id;
    labelListaProdutos = document.data()["label"];
    quantidade = document.data()["quantidade"];
    preco = document.data()["preco"];
    produto = Produto();
    produto.setID = document.data()["id"];
  }
}
