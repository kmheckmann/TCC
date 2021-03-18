import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Categoria.dart';

class CategoriaController {
  bool _existeCadastro;
  Categoria _categoria = Categoria();

  bool get getExisteCad {
    return _existeCadastro;
  }

  set setExisteCad(bool existeCad) {
    _existeCadastro = existeCad;
  }

  Categoria get getCategoria {
    return _categoria;
  }

  set setCategoria(Categoria cat) {
    _categoria = cat;
  }

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
    _existeCadastro = false;
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
        _existeCadastro = true;
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
            _existeCadastro = true;
          }
        });
      }
    }
  }

  Future<Null> obterCategoria(String id) async {
    Categoria c;
    //Usado para obter os dados da categoria selecionada no produto
    if (id.contains(" - ")) {
      var array = id.split(" - ");
      id = array[0];
    }

    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection("categorias").doc(id).get();
    _categoria.setID = id;
    _categoria.setDescricao = doc.data()["descricao"];
    _categoria.setAtiva = doc.data()["ativa"];
  }
}
