import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/controller/CategoriaController.dart';
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
  Produto produto;
  final DocumentSnapshot snapshot;

  _TelaCRUDProdutoState({this.produto, this.snapshot});

  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();
  final _controllerCodigo = TextEditingController();
  final _controllerDescricao = TextEditingController();
  final _controllerCodBarra = TextEditingController();
  final _controllerPercentualLucro = TextEditingController();
  ProdutoController controllerProduto = ProdutoController();
  CategoriaController controllerCategoria = CategoriaController();
  Categoria categoria;
  bool _existeCadastroCodigo;
  bool _existeCadastroCodigoBarra;
  bool _novocadastro;
  String _nomeTela;
  String _dropdownValueCategoria;

  @override
  void initState() {
    super.initState();
    _existeCadastroCodigo = false;
    _existeCadastroCodigoBarra = false;

    if (produto != null) {
      _nomeTela = "Editar Produto";
      _novocadastro = false;
      categoria = produto.categoria;
      _controllerCodigo.text = produto.codigo.toString();
      _controllerCodBarra.text = produto.codBarra.toString();
      _controllerPercentualLucro.text = produto.percentualLucro.toString();
      _dropdownValueCategoria = produto.categoria.descricao;
      _controllerDescricao.text = produto.descricao;
    } else {
      _nomeTela = "Cadastrar Produto";
      produto = Produto();
      produto.ativo = true;
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
          onPressed: () async {
            await controllerCategoria
                .obterCategoriaPorDescricao(_dropdownValueCategoria);
            this.categoria = controllerCategoria.categoria;
            if (_validadorCampos.currentState.validate()) {
              if (_dropdownValueCategoria != null) {
                Map<String, dynamic> mapa =
                    controllerProduto.converterParaMapa(produto);
                Map<String, dynamic> mapaCategoria = Map();
                mapaCategoria["id"] = categoria.id;
                if (_novocadastro) {
                  await controllerProduto.obterProxID();
                  produto.id = controllerProduto.proxID;
                  controllerProduto.salvarProduto(
                      mapa, mapaCategoria, produto.id);
                } else {
                  controllerProduto.editarProduto(
                      mapa, mapaCategoria, produto.id);
                }
                Navigator.of(context).pop();
              } else {
                _scaffold.currentState.showSnackBar(SnackBar(
                  content: Text("É necessário selecionar uma Categoria!"),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                ));
              }
            }
          }),
      body: Form(
        key: _validadorCampos,
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: <Widget>[
            _criarCampoText(
                _controllerCodigo, "Código", TextInputType.number, true),
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

  Widget _criarCampoText(TextEditingController controller, String nome,
      TextInputType tipo, bool enabled) {
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          enabled: enabled,
          controller: controller,
          keyboardType: tipo,
          decoration: InputDecoration(
            hintText: nome,
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
            if (text.isEmpty) return "É necessário informar este campo!";
            if (nome == "Código" && _existeCadastroCodigo && text.isNotEmpty)
              return "Já existe um produto com esse código, verifique!";
            if (nome == "Código de Barra" &&
                _existeCadastroCodigoBarra &&
                text.isNotEmpty)
              return "Já existe um produto com esse código de barras, verifique!";
          },
          onChanged: (texto) async {
            switch (nome) {
              case "Descrição":
                produto.descricao = texto;
                break;
              case "Código":
                produto.codigo = int.parse(texto);
                await controllerProduto
                    .verificarExistenciaCodigoProduto(produto.codigo);
                _existeCadastroCodigo = controllerProduto.existeCadastroCodigo;
                break;
              case "Percentual Lucro":
                produto.percentualLucro = double.parse(texto);
                break;
              case "Código de Barra":
                produto.codBarra = int.parse(texto);
                await controllerProduto
                    .verificarExistenciaCodigoBarrasProduto(produto.codBarra);
                _existeCadastroCodigoBarra =
                    controllerProduto.existeCadastroCodigoBarra;
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
            value: produto.ativo == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  produto.ativo = true;
                } else {
                  produto.ativo = false;
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
        stream: Firestore.instance
            .collection('categorias')
            .where("ativa", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var length = snapshot.data.documents.length;
            DocumentSnapshot ds = snapshot.data.documents[length - 1];
            return Container(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 300.0,
                    child: DropdownButton(
                      value: _dropdownValueCategoria,
                      hint: Text("Selecionar categoria"),
                      onChanged: (String newValue) {
                        setState(() {
                          _dropdownValueCategoria = newValue;
                        });
                      },
                      items: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return DropdownMenuItem<String>(
                            value: document.data()['descricao'],
                            child: Container(
                              child: Text(document.data()['descricao'],
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
