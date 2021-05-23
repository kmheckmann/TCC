import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/controller/ItemPedidoController.dart';
import 'package:tcc_3/model/ItemPedido.dart';

class ItemPedidoCompraController extends ItemPedidoController {
  ItemPedidoCompraController();

  @override
  void persistirItem(ItemPedido item, String idPedido, String idProduto,
      Map<String, dynamic> dadosPedido) {
    setDadosPedido = dadosPedido;

    //Grava as informações do item do pedido
    FirebaseFirestore.instance
        .collection("pedidos")
        .doc(idPedido)
        .collection("itens")
        .doc(item.id)
        .set(item.converterParaMapa(idProduto));
    //Informações do item podem influenciar em valores da capa do pedido, como preço total, ao salvar os itens
    //salva também as atualizações que podem ter tido no pedido em si
    FirebaseFirestore.instance
        .collection("pedidos")
        .doc(idPedido)
        .set(dadosPedido);
  }

  @override
  void removerItem(ItemPedido item, String idItem, String idPedido,
      Map<String, dynamic> dadosPedido) {
    FirebaseFirestore.instance
        .collection("pedidos")
        .doc(idPedido)
        .collection("itens")
        .doc(idItem)
        .delete();

    //Ao remover um item atualiza as informações do pedido em si
    FirebaseFirestore.instance
        .collection("pedidos")
        .doc(idPedido)
        .set(dadosPedido);
  }
}
