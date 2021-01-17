import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Categoria.dart';

class CategoriaController {
  bool existeCadastro;
  String proxID;
  CategoriaController();
  Categoria categoria = Categoria();

  Map<String, dynamic> dadosCategoria = Map();

  //converte para mapa para ser possível salvar no banco
  Map<String, dynamic> converterParaMapa(Categoria categoria) {
    return {
      "descricao": categoria.descricao,
      "ativa": categoria.ativa,
    };
  }

  Future<Null> salvarCategoria(
      Map<String, dynamic> dadosCategoria, String id) async {
    this.dadosCategoria = dadosCategoria;
    await Firestore.instance
        .collection("categorias")
        .document(id)
        .setData(dadosCategoria);
  }

  Future<Null> editarCategoria(
      Map<String, dynamic> dadosCategoria, String idFirebase) async {
    this.dadosCategoria = dadosCategoria;
    await Firestore.instance
        .collection("categorias")
        .document(idFirebase)
        .setData(dadosCategoria);
  }

  Future<Null> obterProxID() async {
    int idTemp = 0;
    int docID;
    CollectionReference ref = Firestore.instance.collection("categorias");
    QuerySnapshot eventsQuery = await ref.getDocuments();

    eventsQuery.documents.forEach((document) {
      docID = int.parse(document.documentID);
      if (eventsQuery.documents.length == 0) {
        idTemp = 1;
        proxID = idTemp.toString();
      } else {
        if (docID > idTemp) {
          idTemp = docID;
        }
      }
    });

    idTemp = idTemp + 1;
    proxID = idTemp.toString();
  }

  Future<Null> verificarExistenciaCategoria(Categoria categoria, bool novoCad) async {
    existeCadastro = false;
    //Busca todas as categoria cadastradas
    CollectionReference ref = Firestore.instance.collection("categorias");
    //Nas categorias cadastradas verifica se existe alguma com o mesmo nome e estado informados no cadastro atual
    QuerySnapshot eventsQuery = await ref
        .where("descricao", isEqualTo: categoria.descricao)
        .getDocuments();

    if (novoCad) {
      //Se for um novo cadastro a quantidade de registros nao pode ser maior que zero
      //pois não pode existir registros com a mesma descricao
      if (eventsQuery.documents.length > 0) {
        existeCadastro = true;
      }
    } else {
      //Se não for um novo cadastro, já existe 1 registro,
      //Existe a possibilidade do usuario alterar o texto e depois tentar voltar ao original
      //Para tratar isso será comparado o ID do cadastro existente com o que esta sendo alterado
      //Se forem diferentes, será informado que o cadastro já existe e não será possível salvar
      //Se forem iguais, permite salvar
      if (eventsQuery.documents.length == 1) {
        eventsQuery.documents.forEach((document) {
          if (document.documentID != categoria.id) {
            existeCadastro = true;
          }
        });
      }
    }
  }

  Future<Null> obterCategoriaPorDescricao(String descricao) async {
    CollectionReference ref = Firestore.instance.collection("categorias");
    QuerySnapshot eventsQuery =
        await ref.where("descricao", isEqualTo: descricao).getDocuments();

    eventsQuery.documents.forEach((document) {
      Categoria c = Categoria.buscarFirebase(document);
      c.id = document.documentID;
      categoria = c;
    });
  }
}
