import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/controller/CategoriaController.dart';
import 'package:tcc_3/model/Categoria.dart';

class TelaCRUDCategoria extends StatefulWidget {
  final Categoria categoria;
  DocumentSnapshot snapshot;

  TelaCRUDCategoria({this.categoria, this.snapshot});
  @override
  _TelaCRUDCategoriaState createState() =>
      _TelaCRUDCategoriaState(categoria, snapshot);
}

class _TelaCRUDCategoriaState extends State<TelaCRUDCategoria> {
  Categoria categoria;
  final DocumentSnapshot snapshot;

  _TelaCRUDCategoriaState(this.categoria, this.snapshot);

  final _controllerDescricao = TextEditingController();
  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();
  CategoriaController controllerCategoria = CategoriaController();
  bool _existeCadastro;
  bool _novocadastro;
  String _nomeTela;

  @override
  void initState() {
    super.initState();
    _existeCadastro = false;
    if (categoria != null) {
      _nomeTela = "Editar Categoria";
      _controllerDescricao.text = categoria.descricao;
      _novocadastro = false;
    } else {
      _nomeTela = "Cadastrar Categoria";
      categoria = Categoria();
      categoria.ativa = true;
      _novocadastro = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text(_nomeTela),
        centerTitle: true,
      ),
      //Botao para salvar
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          backgroundColor: Colors.blue,
          onPressed: () async {
            //Verifica se já existe um categoria com as mesmas informações
            await controllerCategoria.verificarExistenciaCategoria(
                categoria, _novocadastro);
            _existeCadastro = controllerCategoria.existeCadastro;

            //verifica se os criterios para permitir salvar um registro foram preenchidos
            if (_validadorCampos.currentState.validate()) {
              Map<String, dynamic> mapa =
                  controllerCategoria.converterParaMapa(categoria);

              if (_novocadastro) {
                await controllerCategoria.obterProxID();
                categoria.id = controllerCategoria.proxID;
                controllerCategoria.salvarCategoria(mapa, categoria.id);
              } else {
                controllerCategoria.editarCategoria(mapa, categoria.id);
              }
              //volta para a listagem de categorias após salvar
              Navigator.of(context).pop();
            }
          }),
      //corpo da tela
      body: Form(
          key: _validadorCampos,
          child: ListView(
            padding: EdgeInsets.all(8.0),
            children: <Widget>[
              TextFormField(
                controller: _controllerDescricao,
                decoration: InputDecoration(
                    labelText: "Nome da categoria",
                    labelStyle: TextStyle(
                        color: Colors.blueGrey, fontWeight: FontWeight.w400)),
                style: TextStyle(color: Colors.black, fontSize: 17.0),
                keyboardType: TextInputType.text,
                //Onde é realizada a validação do form
                validator: (text) {
                  //verifica se o campo está preenchidoe se a categoria já existe, se sim, retorna mensagem
                  if (_existeCadastro) return "Categoria já existe. Verifique!";
                  if (text.isEmpty) return "Informe a descrição!";
                },
                onChanged: (text) {
                  categoria.descricao = text.toUpperCase();
                },
              ),
              _criarCampoCheckBox()
            ],
          )),
    );
  }

  Widget _criarCampoCheckBox() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: categoria.ativa == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  categoria.ativa = true;
                } else {
                  categoria.ativa = false;
                }
              });
            },
          ),
          Text(
            "Ativa?",
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }
}
