import 'package:flutter/material.dart';
import 'package:tcc_3/screens/TelaCategorias.dart';
import 'package:tcc_3/screens/TelaCidades.dart';
import 'package:tcc_3/screens/TelaConsultas.dart';
import 'package:tcc_3/screens/TelaEmpresas.dart';
import 'package:tcc_3/screens/TelaFiltroEstoque.dart';
import 'package:tcc_3/screens/TelaPedidosCompra.dart';
import 'package:tcc_3/screens/TelaPedidosVenda.dart';
import 'package:tcc_3/screens/TelaProdutos.dart';
import 'package:tcc_3/screens/TelaRotas.dart';
import 'package:tcc_3/screens/TelaTrocarSenha.dart';
import 'package:tcc_3/screens/TelaUsuarios.dart';
import 'package:tcc_3/tabs/HomeTab.dart';
import 'package:tcc_3/widgets/Menu.dart';

//Tela inicial do aplicativo após o login
class HomeScreen extends StatelessWidget {
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      //Nao permite que seja possivel trocar as telas do pageView arrastando
      physics: NeverScrollableScrollPhysics(),
      controller: _pageController,
      children: <Widget>[
        //Chamada de cada uma das telas
        Scaffold(
          body: HomeTab(),
          drawer: Menu(_pageController),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Pedidos Venda"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: TelaPedidosVenda(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Empresas"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: TelaEmpresas(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Cidades"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: TelaCidades(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Consulta de Estoque"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: TelaFiltroEstoque(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Rotas"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: TelaRotas(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Produtos"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: TelaProdutos(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Pedidos Compra"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: TelaPedidosCompra(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Usuários"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: TelaUsuarios(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Consultas"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: TelaConsultas(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Categorias"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: TelaCategorias(),
        ),
        Scaffold(
          drawer: Menu(_pageController),
          body: TelaTrocarSenha()
        ),
      ],
    );
  }
}
