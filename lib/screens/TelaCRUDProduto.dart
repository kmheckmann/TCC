import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/acessorios/Campos.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/acessorios/Mensagens.dart';
import 'package:tcc_3/controller/CategoriaController.dart';
import 'package:tcc_3/controller/ObterProxIDController.dart';
import 'package:tcc_3/controller/ProdutoController.dart';
import 'package:tcc_3/model/Categoria.dart';
import 'package:tcc_3/model/Produto.dart';

class TelaCRUDProduto extends StatefulWidget {
  final Produto produto;
  final DocumentSnapshot snapshot;

  TelaCRUDProduto({this.produto, this.snapshot});

  @override
  _TelaCRUDProdutoState createState() =>
      _TelaCRUDProdutoState(produto: produto, snapshot: snapshot);
}

class _TelaCRUDProdutoState extends State<TelaCRUDProduto> {
  final DocumentSnapshot snapshot;
  Produto produto;

  _TelaCRUDProdutoState({this.produto, this.snapshot});

  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();
  final _controllerID = TextEditingController();
  final _controllerDescricao = TextEditingController();
  final _controllerCodBarra = TextEditingController();
  final _controllerPercentualLucro = TextEditingController();

  ProdutoController controllerProduto = ProdutoController();
  CategoriaController controllerCategoria = CategoriaController();
  ObterProxIDController obterProxID = ObterProxIDController();
  Mensagens msg = Mensagens();
  Campos campos = Campos();
  Cores cores = Cores();

  Categoria categoria;
  bool _existeCadastroCodigoBarra;
  bool _novocadastro;
  String _nomeTela;
  String _dropdownValueCategoria;

  @override
  void initState() {
    super.initState();

    if (produto != null) {
      _nomeTela = "Editar Produto";
      _novocadastro = false;
      categoria = produto.getCategoria;
      _controllerID.text = produto.getID;
      _controllerCodBarra.text = produto.getCodBarra.toString();
      _controllerPercentualLucro.text = produto.getPercentLucro.toString();
      _dropdownValueCategoria = produto.getCategoria.getID +
          ' - ' +
          produto.getCategoria.getDescricao;
      _controllerDescricao.text = produto.getDescricao;
    } else {
      _nomeTela = "Cadastrar Produto";
      produto = Produto();
      produto.setAtivo = true;
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
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          backgroundColor: Colors.blue,
          onPressed: () {
            _codigoBotaoSalvar();
          }),
      body: Form(
        key: _validadorCampos,
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: <Widget>[
            campos.campoTextoDesabilitado(_controllerID, "Código", false),
            _criarCampoText(
                _controllerDescricao, "Descrição", TextInputType.text, true),
            _criarCampoText(_controllerCodBarra, "Código de Barra",
                TextInputType.number, true),
            _criarCampoText(_controllerPercentualLucro, "Percentual Lucro",
                TextInputType.number, true),
            _criarDropDownCategoria(),
            _criarCampoCheckBox()
          ],
        ),
      ),
    );
  }

  void _codigoBotaoSalvar() async {
    if (_dropdownValueCategoria != null) {
      await controllerCategoria.obterCategoria(_dropdownValueCategoria);
      this.categoria = controllerCategoria.categoria;
    }

    if (_controllerCodBarra.text.isNotEmpty) {
      await controllerProduto.verificarExistenciaCodigoBarrasProduto(
          produto.getCodBarra, _novocadastro);
      _existeCadastroCodigoBarra = controllerProduto.existeCadastroCodigoBarra;
    }

    if (_validadorCampos.currentState.validate()) {
      if (_dropdownValueCategoria != null) {
        Map<String, dynamic> mapa =
            controllerProduto.converterParaMapa(produto);
        Map<String, dynamic> mapaCategoria = Map();
        mapaCategoria["id"] = categoria.getID;
        if (_novocadastro) {
          await obterProxID.obterProxID("produtos");
          produto.setID = obterProxID.proxID;
          controllerProduto.persistirProduto(
              mapa, mapaCategoria, produto.getID);
        } else {
          controllerProduto.persistirProduto(
              mapa, mapaCategoria, produto.getID);
        }
        Navigator.of(context).pop();
      } else {
        msg.exibirBarraMensagem(
            "É necessário selecionar uma Categoria!", Colors.red, _scaffold);
      }
    }
  }

  Widget _criarCampoText(TextEditingController controller, String nome,
      TextInputType tipo, bool enabled) {
    return Container(
        child: TextFormField(
      enabled: enabled,
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(
          hintText: nome,
          labelText: nome,
          labelStyle:
              TextStyle(color: cores.corLabel(), fontWeight: FontWeight.w400)),
      style: TextStyle(color: cores.corCampo(enabled), fontSize: 17.0),
      validator: (text) {
        if (text.isEmpty) return "É necessário informar este campo!";
        if (nome == "Código de Barra" &&
            _existeCadastroCodigoBarra &&
            text.isNotEmpty)
          return "Já existe um produto com esse código de barras, verifique!";
      },
      onChanged: (texto) async {
        switch (nome) {
          case "Descrição":
            produto.setDescricao = texto.toUpperCase();
            break;
          case "Percentual Lucro":
            produto.setPercentLucro = double.parse(texto);
            break;
          case "Código de Barra":
            produto.setCodBarra = int.parse(texto);
            break;
        }
      },
    ));
  }

  Widget _criarCampoCheckBox() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: produto.getAtivo == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  produto.setAtivo = true;
                } else {
                  produto.setAtivo = false;
                }
              });
            },
          ),
          Text(
            "Ativo?",
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  Widget _criarDropDownCategoria() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categorias')
            .where("ativa", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var length = snapshot.data.docs.length;
            DocumentSnapshot ds = snapshot.data.docs[length - 1];
            return Container(
              padding: EdgeInsets.only(top: 5.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 300.0,
                    child: DropdownButton(
                      value: _dropdownValueCategoria,
                      hint: Text(
                        "Selecionar categoria",
                        style: TextStyle(
                            color: cores.corCampo(true), fontSize: 17.0),
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          _dropdownValueCategoria = newValue;
                        });
                      },
                      items:
                          snapshot.data.docs.map((DocumentSnapshot document) {
                        return DropdownMenuItem<String>(
                            value: document.id +
                                ' - ' +
                                document.data()['descricao'],
                            child: Container(
                              child: Text(
                                  document.id +
                                      ' - ' +
                                      document.data()['descricao'],
                                  style: TextStyle(color: Colors.black)),
                            ));
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}
