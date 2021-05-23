import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:tcc_3/controller/PedidoController.dart';
import 'package:tcc_3/model/ItemPedido.dart';
import 'package:tcc_3/model/Pedido.dart';
import 'package:tcc_3/model/PedidoCompra.dart';

class PedidoCompraController extends PedidoController {
  PedidoCompra pedidoCompra = PedidoCompra();

  PedidoCompraController();

  Map<String, dynamic> converterParaMapa(Pedido p) {
    return {
      "valorTotal": p.getValorTotal + 0.0,
      "percentualDesconto": p.getPercentDesconto,
      "tipoPagamento": p.getTipoPgto,
      "ehPedidoVenda": p.getEhPedidoVenda,
      "dataPedido": p.getDataPedido,
      "pedidoFinalizado": p.getPedidoFinalizado,
      "label": p.getLabel,
      "valorComDesconto": p.getValorDesconto,
      "dataFinalPedido": p.getDataFinal,
    };
  }

  Future<Null> persistirAlteracoesPedido(
      Map<String, dynamic> dadosPedido,
      Map<String, dynamic> dadosEmpresa,
      Map<String, dynamic> dadosUsuario,
      String idPedido) async {
    this.setDadosPedido = dadosPedido;
    this.setDadosEmpresa = dadosEmpresa;
    this.setDadosUser = dadosUsuario;

    //Grava os dados do pedido
    await FirebaseFirestore.instance
        .collection("pedidos")
        .doc(idPedido)
        .set(dadosPedido);

    //Salva dentro da collection pedido o ID do cliente do pedido
    await FirebaseFirestore.instance
        .collection("pedidos")
        .doc(idPedido)
        .collection("cliente")
        .doc("IDcliente")
        .set(dadosEmpresa);
    //Salva dentro da collection pedido o ID do vendedor
    await FirebaseFirestore.instance
        .collection("pedidos")
        .doc(idPedido)
        .collection("vendedor")
        .doc("IDvendedor")
        .set(dadosUsuario);
  }

  //Aplica no valor total do pedido o desconto informado
  @override
  void calcularDesconto(Pedido p) {
    if (p.getValorTotal != 0 || p.getValorTotal == 0) {
      double vlDesc = (p.getPercentDesconto / 100) * p.getValorTotal;
      pedidoCompra.setValorDesconto = (p.getValorTotal - vlDesc);
      pedidoCompra.setValorDesconto =
          num.parse(pedidoCompra.getValorDesconto.toStringAsFixed(2));
    } else {
      //Exceção para o caso de o desconto ser informado antes do pedido ter algum valor
      pedidoCompra.setValorDesconto = 0;
    }
  }

  //Método chamado para atualizar regularmente o valor total do pedido
  @override
  void somarPrecoNoVlTotal(Pedido p, ItemPedido novoItem) {
    double valorTotalItem = novoItem.preco * novoItem.quantidade;
    p.setValorTotal = p.getValorTotal + valorTotalItem;
    pedidoCompra.setValorTotal = p.getValorTotal;
    pedidoCompra.setValorTotal =
        num.parse(pedidoCompra.getValorTotal.toStringAsFixed(2));
    calcularDesconto(p);
  }

  //Método utilizado quando é realizada uma alteração num item do pedido
  void atualizarPrecoNoVlTotal(double precoAntigo, Pedido p, ItemPedido item) {
    //Diminui o valor total antigo obtido com a soma das quantidade do item
    double vlTotalItemAntigo = precoAntigo * item.quantidade;
    p.setValorTotal = p.getValorTotal - vlTotalItemAntigo;
    //Após diminuir, chama o método abaixo para somar o novo valor no pedido
    somarPrecoNoVlTotal(p, item);
  }

  //Método utilizado quando um item é removido, para diminuir seu valor do valor total do pedido
  void subtrairPrecoVlTotal(Pedido p, ItemPedido itemExcluido) {
    double valorTotalItem = itemExcluido.preco * itemExcluido.quantidade;
    p.setValorTotal = p.getValorTotal - valorTotalItem;
    pedidoCompra.setValorTotal = p.getValorTotal;
    calcularDesconto(p);
  }

  //Método chamado ao utilizar o botão de atualizar na capa do pedido
  @override
  Future atualizarCapaPedido(String idPedido, VoidCallback terminou) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('pedidos');
    QuerySnapshot _obterPedido = await ref.get();

    _obterPedido.docs.forEach((document) {
      if (idPedido == document.id) {
        pedidoCompra = PedidoCompra.buscarFirebase(document);
      }
    });
    terminou();
  }
}
