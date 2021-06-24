import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:tcc_3/controller/ObterProxIDController.dart';
import 'package:tcc_3/controller/ProdutoController.dart';
import 'package:tcc_3/model/EstoqueProduto.dart';
import 'package:tcc_3/model/Pedido.dart';
import 'package:tcc_3/model/PedidoVenda.dart';
import 'package:tcc_3/model/Produto.dart';

class EstoqueProdutoController {
  ObterProxIDController _controllerProxID = ObterProxIDController();

  EstoqueProdutoController();

  Map<String, dynamic> _dadosEstoqueProduto = Map();
  ProdutoController _controllerProduto = ProdutoController();
  List<EstoqueProduto> _estoques = [];
  List<Produto> _produtos = [];
  bool _produtoTemEstoque = false;
  bool _permitirFinalizarPedidoVenda;
  int _qtdeExistente = 0;
  double _precoVenda = 0;

  List<EstoqueProduto> get getEstoques {
    return _estoques;
  }

  set setEstoques(List<EstoqueProduto> estoques) {
    _estoques = estoques;
  }

  List<Produto> get getProdutos {
    return _produtos;
  }

  set setProdutos(List<Produto> prods) {
    _produtos = prods;
  }

  bool get getProdutoTemEstoque {
    return _produtoTemEstoque;
  }

  set setProdutoTemEstoque(bool tem) {
    _produtoTemEstoque = tem;
  }

  bool get getPermitirFinalizarPedidoVenda {
    return _permitirFinalizarPedidoVenda;
  }

  set setPermitirFinalizarPedidoVenda(bool permite) {
    _permitirFinalizarPedidoVenda = permite;
  }

  int get getQtdeExistente {
    return _qtdeExistente;
  }

  set setQtdeExistente(int qtde) {
    _qtdeExistente = qtde;
  }

  double get getPrecoVenda {
    return _precoVenda;
  }

  set setPrecoVenda(double precoVenda) {
    _precoVenda = precoVenda;
  }

  Map<String, dynamic> converterParaMapa(EstoqueProduto estoqueProduto) {
    return {
      "dtAquisicao": estoqueProduto.dataAquisicao,
      "quantidade": estoqueProduto.quantidade,
      "precoCompra": estoqueProduto.precoCompra,
    };
  }

  Future<Null> salvarEstoqueProduto(Map<String, dynamic> dadosEstoqueProduto,
      String idProduto, String idEstoque) async {
    _dadosEstoqueProduto = dadosEstoqueProduto;
    await FirebaseFirestore.instance
        .collection("produtos")
        .doc(idProduto)
        .collection("estoque")
        .doc(idEstoque)
        .set(_dadosEstoqueProduto);
  }

//Método chamado ao finalizar o pedido de compra
  Future<Null> gerarEstoque(Pedido p) async {
    //Busca os dados do pedido
    CollectionReference ref = FirebaseFirestore.instance
        .collection("pedidos")
        .doc(p.getID)
        .collection("itens");
    QuerySnapshot _obterItens = await ref.get();

//Para cada item do pedido obtem a quantidade e o preço da compra e salva um novo lote do produto
//Aumentando a quantidade em estoque deste item
    _obterItens.docs.forEach((item) {
      EstoqueProduto estoque = EstoqueProduto();
      estoque.dataAquisicao = DateTime.now();
      estoque.quantidade = item["quantidade"];
      estoque.precoCompra = item["preco"];
      estoque.id =
          _controllerProxID.proxIDEstoque(p, item.id, estoque.dataAquisicao);
      Map<String, dynamic> mapa = converterParaMapa(estoque);
      salvarEstoqueProduto(mapa, item.data()["id"], estoque.id);
    });
  }

  //Método usado na consulta de estoque
  Future obterEstoqueProduto({String id, VoidCallback terminou}) async {
    List<EstoqueProduto> estoquesTemp = [];
    _qtdeExistente = 0;
    //Obtém todos os estoque disponiveis
    CollectionReference ref = FirebaseFirestore.instance
        .collection("produtos")
        .doc(id)
        .collection("estoque");
    QuerySnapshot _obterEstoque =
        await ref.where("quantidade", isGreaterThan: 0).get();

    //Adiciona cada registro na lista
    _obterEstoque.docs.forEach((document) {
      EstoqueProduto e = EstoqueProduto();
      e = EstoqueProduto.buscarFirebase(document);
      estoquesTemp.add(e);
    });

    _estoques = estoquesTemp;

    if (terminou != null) {
      terminou();
    }
  }

  Future retornarQtdeExistente({String id, VoidCallback terminou}) {
    //obtem o estoque do produto
    obterEstoqueProduto(id: id).whenComplete(() {
      //percorre a lista de estoque
      _estoques.forEach((p) {
        if (_estoques.length > 0) {
          //soma na quantidade existente a quantidade que está sendo observada na lista
          _qtdeExistente += p.quantidade;
        }
      });
      //Se for passado um VoidCallBack por parametro, executa o voidcallback
      if (terminou != null) {
        terminou();
      }
    });
  }

  //Esse método será usado no pedido de venda
  //Ao salvar um item de pedido que nao tenha estoque com a quantidade desejada será exibido um aviso
  //Mas permiirá salvar o item
  //Ao tentar finalizar um pedido onde um dos itens não possui em estoque a quantidade desejada a operação será abortada
  Future<Null> verificarSeProdutoTemEstoqueDisponivel(
      String id, int quantidadeDesejada, VoidCallback terminou) async {
    //Contador para a quantidade de todos os lotes do item
    _qtdeExistente = 0;
    //Chama o método abaixo para obter todo o estoque do item
    obterEstoqueProduto(id: id);

    //para cada registro existente, adicionada no contador a quantidade total do lote do estoque
    _estoques.forEach((estoqueProduto) {
      _qtdeExistente += estoqueProduto.quantidade;
    });

    //Se a quantidade existente de estoque for maior ou igual a desejada, atribui true na variavel
    if (_qtdeExistente >= quantidadeDesejada) _produtoTemEstoque = true;
    terminou();
  }

//Esse método será utilizado no pedido de venda após constatar que existe estoque suficiente disponivel do produto desejado
  Future<Null> descontarEstoqueProduto(Pedido p) async {
    int contador;
    CollectionReference ref = Firestore.instance
        .collection("pedidos")
        .document(p.getID)
        .collection("itens");

    QuerySnapshot _obterItens = await ref.getDocuments();

    _obterItens.documents.forEach((item) async {
      contador = 0;
      await _controllerProduto.obterProdutoPorID(id: item.data()["id"]);
      Produto prod = _controllerProduto.produto;
      //Contador da lista
      //recebe a quantidade desejada do produto
      int qtdeDesejada = item.data()["quantidade"];

      //Obtem todo o estoque do produto
      await obterEstoqueProduto(id: prod.getID);
      //Enquanto a quantidade desejada nao estiver zerada será realizado a ação abaixo
      do {
        //Se o lote verificado possuir quantidade maior do que a qtde desejada
        //Subtrai o valor da quantidade desejada e salva a quantidade restante no banco
        if (_estoques[contador].quantidade > qtdeDesejada) {
          _estoques[contador].quantidade -= qtdeDesejada;
          qtdeDesejada = 0;
        } else {
          //Caso o lote tenha quantidade menor que a qtde desejada
          //Remove-se da quantidade desejada o que o produto tem de quantidade no estoque
          //Zera a quantidade de estoque do item e salva isso no banco
          //Repete o processo até a quantidade desejada ficar zerada
          qtdeDesejada -= _estoques[contador].quantidade;
          _estoques[contador].quantidade = 0;
        }
        Map<String, dynamic> mapa = converterParaMapa(_estoques[contador]);
        salvarEstoqueProduto(mapa, prod.getID, _estoques[contador].id);
        contador += 1;
      } while (qtdeDesejada != 0);
    });
  }

  Future<Null> verificarEstoqueTodosItensPedido(PedidoVenda pedido) async {
    //Metodo criado para verificar se todos os itens do pedido possuem estoque
    //se sim, sera possível finalizar o pedido, caso contrário não será permitido
    CollectionReference ref = FirebaseFirestore.instance
        .collection("pedidos")
        .doc(pedido.getID)
        .collection("itens");

    QuerySnapshot _obterItens = await ref.get();
    _obterItens.docs.forEach((item) async {
      Produto prod = Produto();
      int qtdeDesejada;
      _controllerProduto
          .obterProdutoPorID(id: item.data()["id"])
          .whenComplete(() {
        prod = _controllerProduto.produto;
        //prod = await _controllerProduto.obterProdutoPorID(item.data["id"]);
        print("1 aqui");
        print(prod.getDescricao);
        print(item.data()["quantidade"]);
        //Contador da lista
        //recebe a quantidade desejada do produto
        qtdeDesejada = item.data()["quantidade"];
      });

      _qtdeExistente = 0;
      //Chama o método abaixo para obter todo o estoque do item
      await obterEstoqueProduto(id: prod.getID).whenComplete(() {
        print("aqui 2");
        print(_estoques.length);
        print(_qtdeExistente);

        //para cada registro existente, adicionada no contador a quantidade total do lote do estoque
        _estoques.forEach((estoqueProduto) {
          _qtdeExistente += estoqueProduto.quantidade;
          print(_qtdeExistente);
          print(qtdeDesejada);

          if (qtdeDesejada >= _qtdeExistente) {
            _qtdeExistente = 0;
            _permitirFinalizarPedidoVenda = false;
          }
        });
      });
    });

    // return Future.value(permitirFinalizarPedidoVenda);
  }

//O metodo ira aplicar no maior preco de compra do item o percentual de lucro definido no cadastro do produto
  Future obterPrecoVenda(Produto p, VoidCallback terminou) async {
    double preco = 0;
    double maiorPrecoCompra = 0;

    await obterEstoqueProduto(id: p.getID);

    _estoques.forEach((item) {
      preco = item.precoCompra;
      if (preco > maiorPrecoCompra) {
        maiorPrecoCompra = preco;
      }
    });

    _precoVenda =
        ((p.getPercentLucro / 100) * maiorPrecoCompra) + maiorPrecoCompra;

    terminou();
  }
}
