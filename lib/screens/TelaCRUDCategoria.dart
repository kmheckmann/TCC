import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/acessorios/Campos.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/controller/ObterProxIDController.dart';
import 'package:tcc_3/controller/CategoriaController.dart';
import 'package:tcc_3/model/Categoria.dart';

class TelaCRUDCategoria extends StatefulWidget {
  final Categoria categoria;
  final DocumentSnapshot snapshot;

  TelaCRUDCategoria({this.categoria, this.snapshot});
  @override
  _TelaCRUDCategoriaState createState() =>
      _TelaCRUDCategoriaState(categoria, snapshot);
}

class _TelaCRUDCategoriaState extends State<TelaCRUDCategoria> {
  final DocumentSnapshot snapshot;
  Categoria categoria;

  _TelaCRUDCategoriaState(this.categoria, this.snapshot);

  ObterProxIDController proxID = ObterProxIDController();
  CategoriaController controllerCategoria = CategoriaController();
  Cores cores = Cores();
  Campos campos = Campos();

  final _controllerDescricao = TextEditingController();
  final _controllerID = TextEditingController();
  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();

  bool _existeCadastro;
  bool _novocadastro;
  String _nomeTela;

  @override
  void initState() {
    super.initState();
    _existeCadastro = false;
    if (categoria != null) {
      _nomeTela = "Editar Categoria";
      _controllerDescricao.text = categoria.getDescricao;
      _controllerID.text = categoria.getID;
      _novocadastro = false;
    } else {
      _nomeTela = "Cadastrar Categoria";
      categoria = Categoria();
      categoria.setAtiva = true;
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
            _codigoBotaoSalvar();
          }),
      //corpo da tela
      body: Form(
          key: _validadorCampos,
          child: ListView(
            padding: EdgeInsets.all(8.0),
            children: <Widget>[
              campos.campoTextoDesabilitado(_controllerID, "Código", false),
              _criarCampoDescricao(),
              _criarCampoCheckBox()
            ],
          )),
    );
  }

  void _codigoBotaoSalvar() async {
    if (_controllerDescricao.text.isNotEmpty) {
      //Verifica se já existe um categoria com as mesmas informações
      await controllerCategoria.verificarExistenciaCategoria(
          categoria, _novocadastro);
      _existeCadastro = controllerCategoria.getExisteCad;
    }

    //verifica se os criterios para permitir salvar um registro foram preenchidos
    if (_validadorCampos.currentState.validate()) {
      Map<String, dynamic> mapa =
          controllerCategoria.converterParaMapa(categoria);

      if (_novocadastro) {
        await proxID.obterProxID("categorias");
        categoria.setID = proxID.proxID;
        controllerCategoria.persistirCategoria(mapa, categoria.getID);
      } else {
        controllerCategoria.persistirCategoria(mapa, categoria.getID);
      }

      //volta para a listagem de categorias após salvar
      Navigator.of(context).pop();
    }
  }

  Widget _criarCampoDescricao() {
    return TextFormField(
      controller: _controllerDescricao,
      decoration: InputDecoration(
          hintText: "Descrição da categoria",
          labelText: "Descrição da categoria",
          labelStyle:
              TextStyle(color: cores.corLabel(), fontWeight: FontWeight.w400)),
      style: TextStyle(color: Colors.black, fontSize: 17.0),
      keyboardType: TextInputType.text,
      //Onde é realizada a validação do form
      validator: (text) {
        //verifica se o campo está preenchidoe se a categoria já existe, se sim, retorna mensagem
        if (_existeCadastro) return "Categoria já existe. Verifique!";
        if (text.isEmpty) return "Informe a descrição!";
      },
      onChanged: (text) {
        categoria.setDescricao = text.toUpperCase();
      },
    );
  }

  Widget _criarCampoCheckBox() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: categoria.getAtiva == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  categoria.setAtiva = true;
                } else {
                  categoria.setAtiva = false;
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
