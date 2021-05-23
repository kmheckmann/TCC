import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/controller/ProdutoController.dart';
import 'package:tcc_3/model/ItemPedido.dart';
import 'package:tcc_3/model/Produto.dart';

abstract class ItemPedidoController {
  Produto _produto = Produto();
  Map<String, dynamic> _dadosPedido = Map();
  ProdutoController _controllerProduto = ProdutoController();

  Map<String, dynamic> get getDadosPedido {
    return _dadosPedido;
  }

  set setDadosPedido(Map<String, dynamic> dadosPedido) {
    _dadosPedido = dadosPedido;
  }

  Produto get getProduto {
    return _produto;
  }

  set setProduto(Produto prod) {
    _produto = prod;
  }

  void persistirItem(ItemPedido item, String idPedido, String idProduto,
      Map<String, dynamic> dadosPedido);

  void removerItem(ItemPedido item, String idItem, String idPedido,
      Map<String, dynamic> dadosPedido);

  //Método utilizado na classe a onde apresenta as listagens dos itens dos pedidos
  //Para obter todos os itens do pedido e as informações do produto do item do pedido
  Future obterProduto(String idPedido) async {
    Produto prod = Produto();

    //Carrega a coleção de itens de pedido
    CollectionReference ref = FirebaseFirestore.instance
        .collection('pedidos')
        .doc(idPedido)
        .collection('itens');
    QuerySnapshot obterProduto = await ref.get();

    //Papa cada documento da coleção, pega o ID e busca as informações do produto pelo ID
    obterProduto.docs.forEach((document) {
      _controllerProduto.obterProdutoPorID(id: document.data()["id"]);
      prod.setID = document.data()["id"];
      prod = _controllerProduto.produto;
    });
    setProduto = prod;
  }
}
