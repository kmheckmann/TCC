import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              //Quando rolar a tela para baixo a barra some,
              //ao rolar um pouco pra cima a barra aparece
              snap: true,
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 0.0,
              flexibleSpace: FlexibleSpaceBar(
                //Const para saber que o texto sempre vai ter o mesmo valor, otimizando o codgio
                title: const Text("Vale Distribuidora"),
                centerTitle: true,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 600,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      "Bem Vindo!",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor, fontSize: 22.0),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              ),
            )
          ],
        ),
      ],
    );
  }
}
