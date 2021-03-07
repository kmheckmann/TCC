import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Categoria.dart';

class CategoriaController {
  bool existeCadastro;
  Categoria categoria = Categoria();

  CategoriaController();

  Map<String, dynamic> dadosCategoria = Map();

  //converte para mapa para ser possível salvar no banco
  Map<String, dynamic> converterParaMapa(Categoria categoria) {
    return {
      "descricao": categoria.getDescricao,
      "ativa": categoria.getAtiva,
    };
  }

  Future<Null> persistirCategoria(
      Map<String, dynamic> dadosCategoria, String id) async {
    this.dadosCategoria = dadosCategoria;
    await FirebaseFirestore.instance
        .collection("categorias")
        .doc(id)
        .set(dadosCategoria);
  }

  Future<Null> verificarExistenciaCategoria(
      Categoria categoria, bool novoCad) async {
    existeCadastro = false;
    //Busca todas as categoria cadastradas
    CollectionReference ref =
        FirebaseFirestore.instance.collection("categorias");
    //Nas categorias cadastradas verifica se existe alguma com o mesmo nome e estado informados no cadastro atual
    QuerySnapshot eventsQuery =
        await ref.where("descricao", isEqualTo: categoria.getDescricao).get();

    if (novoCad) {
      //Se for um novo cadastro a quantidade de registros nao pode ser maior que zero
      //pois não pode existir registros com a mesma descricao
      if (eventsQuery.docs.length > 0) {
        existeCadastro = true;
      }
    } else {
      //Se não for um novo cadastro, já existe 1 registro,
      //Existe a possibilidade do usuario alterar o texto e depois tentar voltar ao original
      //Para tratar isso será comparado o ID do cadastro existente com o que esta sendo alterado
      //Se forem diferentes, será informado que o cadastro já existe e não será possível salvar
      //Se forem iguais, permite salvar
      if (eventsQuery.docs.length == 1) {
        eventsQuery.docs.forEach((document) {
          if (document.id != categoria.getID) {
            existeCadastro = true;
          }
        });
      }
    }
  }

  Future<Null> obterCategoriaPorDescricao(String descricao) async {
    //Usado para obter os dados da categoria selecionada no produto
    //Como não existe mais de uma categoria com a mesma descrição
    //não há problema em procurar pela descrição e não pelo ID
    CollectionReference ref = FirebaseFirestore.instance.collection("categorias");
    QuerySnapshot eventsQuery =
        await ref.where("descricao", isEqualTo: descricao).get();

    eventsQuery.docs.forEach((document) {
      Categoria c = Categoria.buscarFirebase(document);
      c.setID = document.id;
      categoria = c;
    });
  }
}
