import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/model/Produto.dart';

class ProdutoController {
  Produto produto = Produto();
  String _idCategoriaProduto;

  ProdutoController();

  bool existeCadastroCodigoBarra;
  List<Produto> produtos;
  Map<String, dynamic> dadosProduto = Map();
  Map<String, dynamic> dadosCategoria = Map();

  String get getIdCategoriaProduto {
    return _idCategoriaProduto;
  }

  set setAtiva(String idCat) {
    _idCategoriaProduto = idCat;
  }

  Map<String, dynamic> converterParaMapa(Produto produto) {
    return {
      "codBarra": produto.getCodBarra,
      "descricao": produto.getDescricao,
      "percentLucro": produto.getPercentLucro,
      "ativo": produto.getAtivo
    };
  }

  Future<Null> persistirProduto(Map<String, dynamic> dadosProduto,
      Map<String, dynamic> dadosCategoria, String id) async {
    this.dadosProduto = dadosProduto;
    this.dadosCategoria = dadosCategoria;

    //Persiste no banco os dados do produto
    await FirebaseFirestore.instance
        .collection("produtos")
        .doc(id)
        .set(dadosProduto);

//Dentro da collection produto, adiciona uma colletion para a categoria e salva o ID da categoria selecionada neste local
    await FirebaseFirestore.instance
        .collection("produtos")
        .doc(id)
        .collection("categoria")
        .doc("IdCategoria")
        .set(dadosCategoria);
  }

  //Obtem as informações da categoria vinculada ao produto
  Future<Null> obterCategoria(String idProduto) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("produtos")
        .doc(idProduto)
        .collection("categoria")
        .doc("IdCategoria")
        .get();

    _idCategoriaProduto = doc.data()["id"];
  }

  //Garante que não existe outro produto com mesmo codigo de barras antes de salvar o produto
  Future<Null> verificarExistenciaCodigoBarrasProduto(
      int codBarras, bool novoCad) async {
    existeCadastroCodigoBarra = false;
    //Busca todos os produtos cadastrados
    CollectionReference ref = FirebaseFirestore.instance.collection("produtos");
    //Verifica se existe algum com o mesmo codigo informado no cadastro atual
    //se houver atribui true para a variável
    QuerySnapshot eventsQuery =
        await ref.where("codBarra", isEqualTo: codBarras).get();

    if (novoCad) {
      if (eventsQuery.docs.length > 0) {
        existeCadastroCodigoBarra = true;
      }
    } else {
      if (eventsQuery.docs.length == 1) {
        eventsQuery.docs.forEach((document) {
          if (document.data()["codBarra"] != codBarras) {
            existeCadastroCodigoBarra = true;
          }
        });
      }
    }
  }

  //Obtem os demais dados do produto usando o id
  Future obterProdutoPorID({String id, VoidCallback terminou}) async {
    if (id.contains(" - ")) {
      var array = id.split(" - ");
      id = array[0];
    }
    CollectionReference ref = FirebaseFirestore.instance.collection('produtos');
    QuerySnapshot eventsQuery = await ref.get();
    eventsQuery.docs.forEach((document) {
      if (document.id == id) {
        produto = Produto.buscarFirebase(document);
      }
    });
    if (terminou != null) {
      terminou();
    }
  }
}
