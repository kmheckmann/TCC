import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/controller/ItemPedidoController.dart';
import 'package:tcc_3/model/ItemPedido.dart';

class ItemPedidoCompraController extends ItemPedidoController{

  ItemPedidoCompraController();
  
  @override
  void persistirItem(ItemPedido item, String idPedido, String idProduto, Map<String, dynamic> dadosPedido) {
    this.dadosPedido = dadosPedido;

//Grava as informações do item do pedido
    Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .collection("itens")
        .document(item.id)
        .setData(item.converterParaMapa(idProduto));
//Informações do item podem influenciar em valores da capa do pedido, como preço total, ao salvar os itens
//salva também as atualizações que podem ter tido no pedido em si
    Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .setData(dadosPedido);
  }

  @override
  void removerItem(ItemPedido item, String idItem, String idPedido, Map<String, dynamic> dadosPedido) {
    Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .collection("itens")
        .document(idItem)
        .delete();

//Ao remover um item atualiza as informações do pedido em si
    Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .setData(dadosPedido);
  }

}