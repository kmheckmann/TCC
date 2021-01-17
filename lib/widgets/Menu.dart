import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tcc_3/acessorios/BotaoMenu.dart';
import 'package:tcc_3/controller/UsuarioController.dart';

class Menu extends StatelessWidget {
  final PageController pageController;
  bool _ehAdm = false;

  Menu(this.pageController);

  Widget corFundo() => Container(
        decoration: BoxDecoration(color: Color.fromARGB(170, 0, 120, 233)),
      );

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UsuarioController>(rebuildOnChange: true, builder: (context, child, model){
      _ehAdm = model.dadosUsuarioAtual["ehAdm"];
      return Drawer(
      child: Stack(
        children: <Widget>[
          corFundo(),
          ListView(
            padding: EdgeInsets.only(left: 15.0, top: 16.0),
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 8.0),
                padding: EdgeInsets.fromLTRB(0.0, 16.0, 16.0, 8.0),
                height: 100.0,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                        top: 13.0,
                        left: 0.0,
                        child: ScopedModelDescendant<UsuarioController>(
                          builder: (context, child, model) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    "Olá, ${model.dadosUsuarioAtual["nome"]}",
                                    style: TextStyle(
                                        fontSize: 20.0, color: Colors.black)),
                                SizedBox(
                                  height: 7.0,
                                ),
                                GestureDetector(
                                  child: Text(
                                    "Sair",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () {
                                    model.sair();
                                    Navigator.popUntil(
                                        context,
                                        ModalRoute.withName(
                                            Navigator.defaultRouteName));
                                  },
                                )
                              ],
                            );
                          },
                        ))
                  ],
                ),
              ),
              Divider(),
              BotaoMenu(Icons.home, "Início", pageController, 0),
              BotaoMenu(
                  Icons.attach_money, "Pedido de Venda", pageController, 1),
              _ehAdm ? BotaoMenu(Icons.business_center, "Empresas", pageController, 2) : Container(),
              _ehAdm ? BotaoMenu(Icons.location_on, "Cidades", pageController, 3) : Container(),
              BotaoMenu(Icons.store_mall_directory, "Consulta de Estoque",
                  pageController, 4),
              BotaoMenu(Icons.directions_car, "Rotas", pageController, 5),
              _ehAdm ? BotaoMenu(Icons.apps, "Produtos", pageController, 6) : Container(),
              _ehAdm ? BotaoMenu(Icons.add_shopping_cart, "Pedido de Compra",
                  pageController, 7) : Container(),
              _ehAdm ? BotaoMenu(Icons.people, "Usuários", pageController, 8) : Container(),
              BotaoMenu(Icons.assessment, "Consultas", pageController, 9),
              _ehAdm ? BotaoMenu(Icons.bubble_chart, "Categorias", pageController, 10) : Container(),
              BotaoMenu(Icons.assessment, "Relatório", pageController, 11),
            ],
          )
        ],
      ),
    );
    });
  }
}
