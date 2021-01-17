import 'package:tcc_3/model/Pedido.dart';
import 'package:tcc_3/model/Produto.dart';

abstract class ItemPedido {
  String id;
  Produto produto;
  Pedido pedido;
  String categoria;
  int quantidade;
  double preco;
  String labelListaProdutos;
  Map<String, dynamic> dadosItemPedido = Map();

  //Realiza a conversão das informações para mapa para salvar no firebase
//Utilizado na classe PedidoController
  Map<String, dynamic> converterParaMapa(String idProduto) {
    return {
      "id": idProduto,
      "quantidade": quantidade,
      "preco": preco,
      "label": labelListaProdutos
    };
  }
}
